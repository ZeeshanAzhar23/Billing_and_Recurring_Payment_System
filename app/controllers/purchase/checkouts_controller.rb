# frozen_string_literal: true
module Purchase
  class CheckoutsController < ApplicationController
    def create
      @plan = Plan.find(params[:plan_id])
      price = @plan.price_id
      # price = params[:pricing_id]
      session = Stripe::Checkout::Session.create(
        customer: current_user.customer_id,
        client_reference_id: current_user.id,
        success_url: "#{root_url}success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: root_url,
        payment_method_types: ['card'],
        mode: 'subscription',
        line_items: [{
          quantity: 1,
          price: @plan.price_id
        }]
      )
      redirect_to session.url, allow_other_host: true
    end
    def success
      session = Stripe::Checkout::Session.retrieve(params[:session_id])
      @customer = Stripe::Customer.retrieve(session.customer)
    end
  end
end
