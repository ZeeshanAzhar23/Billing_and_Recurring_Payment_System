require "stripe"
class WebhooksController < ApplicationController
  protect_from_forgery :except => [:create]
  skip_before_action :verify_authenticity_token
  # layout false


  def create
    payload = request.body.read
    signature_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_signing_secret)
    event = nil
    if endpoint_secret
      puts 'hello'
      begin
        puts 'hello'
        event = Stripe::Webhook.construct_event(
          payload , signature_header ,endpoint_secret
        )
      # puts event.data.object.type
      puts "hello i am checking for error"
      rescue JSON::ParserError => e
        render json: {message: e}, status: 400
        return
      rescue Stripe::SignatureVerificationError => e
        render json: {message: e}, status: 400
        return
      end
      case event.type
      when 'checkout.session.completed'
        puts 'hello'
       # binding.pry
      #  return if !User.exists?(event.data.object.client_reference_id)

        fullfill_order(event.data.object)

      when 'checkout.session.async_payment_succeeded'

      when 'invoice.payment_succeeded'
        #return if subscription id isn't there in invoice
        return unless event.data.object.subscription.present?
        # continue to provision subscription when the payment is made
        #  update the subscription in app's database
        stripe_subscription=Stripe::Subscription.retrieve(event.data.object.subscription)
        subscription=Subscription.find_by(subscription_id: stripe_subscription)
        subscription.update(
          current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
          current_period_end: Time.at(stripe_subscription.current_period_start).to_datetime,
          status: stripe_subscription.status,
          interval: stripe_subscription.interval,
        )


      when 'invoice.payment_failed'
        # payment failed or simply isn't valid
        # the subscription becomes past_due.
        # Alert the customer through email and send them to stripe customer portal
        user=User.find_by(event.data.object.customer)
        if user.exists?
          SubscriptionMailer.with(user:user).payment_failed_delievered_now
        end

      when 'customer.subscription.updated'
        stripe_subscription=event.data.object
        subscription=Subscription.find_by(subscription_id: stripe_subscription.id)

        if stripe_subscription.cancel_at_period_end == true
        subscription.update(
          current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
          current_period_end: Time.at(stripe_subscription.current_period_start).to_datetime,
          status: stripe_subscription.status,
          interval: stripe_subscription.interval,
          stripe_plan_id: stripe_subscription.plan.id
        )
        end
      when 'customer.subscription.deleted'
        puts "checking delete"
        stripe_subscription=event.data.object
        subscription=Subscription.find_by(subscription_id: stripe_subscription.id)
        if subscription.present?
          subscription.destroy
        end

      else
        puts "Unhandled event type: #{event.type}"
      end
      render json: {message: 'success'}
      end

  end
      private def fullfill_order(checkout_session)
      #Find the stripe subscription through the current customer
        stripe_subscription=Stripe::Subscription.retrieve(checkout_session.subscription)
        puts checkout_session.client_reference_id

        Subscription.create(
          stripe_customer_id: stripe_subscription.customer,
          current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
          current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime,
          stripe_plan_id: stripe_subscription.plan.id,
          interval: stripe_subscription.plan.interval,
          status: stripe_subscription.status,
          subscription_id: stripe_subscription.id,
          user: User.find(checkout_session.client_reference_id),
          plan: Plan.find_by(stripe_plan_id: stripe_subscription.plan.product),
        )
        puts stripe_subscription.plan.product
        puts 'subscription record inserted'
      end
end

