# frozen_string_literal: true
require 'stripe'
class WebhooksController < ApplicationController
  protect_from_forgery except: [:create]
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  def create
    payload = request.body.read
    signature_header = request.env['HTTP_STRIPE_SIGNATURE']
    local_endpoint_secret = Rails.application.credentials.dig(:stripe, :local_webhook_signing_secret)
    production_endpoint_secret = Rails.application.credentials.dig(:stripe,:production_webhook_signing_secret)
    event = nil
    if local_endpoint_secret
      Rails.logger.debug 'hello'
      begin
        Rails.logger.debug 'hello'
        event = Stripe::Webhook.construct_event(
          payload, signature_header, local_endpoint_secret
        )
        Rails.logger.debug 'hello i am checking for error'
      rescue JSON::ParserError => e
        render json: { message: e }, status: :bad_request
        return
      rescue Stripe::SignatureVerificationError => e
        render json: { message: e }, status: :bad_request
        return
      end
      case event.type
      when 'checkout.session.completed'
        fullfill_order(event.data.object)
      when 'invoice.payment_succeeded'
        # return if subscription id isn't there in invoice
        return if event.data.object.subscription.blank?
        # continue to provision subscription when the payment is made
        #  update the subscription in app's database
        stripe_subscription = Stripe::Subscription.retrieve(event.data.object.subscription)
        subscription = Subscription.find_by(subscription_id: stripe_subscription.id)
        subscription.update(
          current_period_start: Time.zone.at(stripe_subscription.current_period_start).to_datetime,
          current_period_end: Time.zone.at(stripe_subscription.current_period_start).to_datetime,
          status: stripe_subscription.status,
          interval: stripe_subscription.interval
        )
      when 'invoice.payment_failed'
        # payment failed or simply isn't valid
        # the subscription becomes past_due.
        # Alert the customer through email and send them to stripe customer portal
        user = User.find_by(event.data.object.customer)
        SubscriptionMailer.with(user: user).payment_failed_delievered_now if user.exists?
      when 'customer.subscription.updated'
        stripe_subscription = event.data.object
        subscription = Subscription.find_by(subscription_id: stripe_subscription.id)
        if stripe_subscription.cancel_at_period_end == true
          subscription.update(
            current_period_start: Time.zone.at(stripe_subscription.current_period_start).to_datetime,
            current_period_end: Time.zone.at(stripe_subscription.current_period_start).to_datetime,
            status: stripe_subscription.status,
            interval: stripe_subscription.interval,
            stripe_plan_id: stripe_subscription.plan.id
          )
        end
      when 'customer.subscription.deleted'
        Rails.logger.debug 'checking delete'
        stripe_subscription = event.data.object
        subscription = Subscription.find_by(subscription_id: stripe_subscription.id)
        subscription.destroy if subscription.present?
      else
        Rails.logger.debug "Unhandled event type: #{event.type}"
      end
      render json: { message: 'success' }
    end
  end
  private def fullfill_order(checkout_session)
    # Find the stripe subscription through the current customer
    stripe_subscription = Stripe::Subscription.retrieve(checkout_session.subscription)
    Rails.logger.debug checkout_session.client_reference_id
    Subscription.create!(
      stripe_customer_id: stripe_subscription.customer,
      current_period_start: Time.zone.at(stripe_subscription.current_period_start).to_datetime,
      current_period_end: Time.zone.at(stripe_subscription.current_period_end).to_datetime,
      stripe_plan_id: stripe_subscription.plan.id,
      interval: stripe_subscription.plan.interval,
      status: stripe_subscription.status,
      subscription_id: stripe_subscription.id,
      user: User.find(checkout_session.client_reference_id),
      plan: Plan.find_by(stripe_plan_id: stripe_subscription.plan.product)
    )
    Rails.logger.debug stripe_subscription.plan.product
    Rails.logger.debug 'subscription record inserted'
  end
end
