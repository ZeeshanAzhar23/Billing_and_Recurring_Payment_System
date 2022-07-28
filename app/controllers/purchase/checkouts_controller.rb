class Purchase::CheckoutsController < ApplicationController
  #before_action :authenticate_user!
 # before_action :retrieve_price_id, only: [:create]
  def create
      @plan=Plan.find(params[:plan_id])
      price=@plan.price_id
      #price = params[:pricing_id]
      session = Stripe::Checkout::Session.create(
        customer: current_user.customer_id,
        client_reference_id: current_user.id,
        success_url: root_url + 'success?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: root_url,
        payment_method_types: ['card'],
        mode: 'subscription',
        # customer_email: current_user.email,
        line_items: [{
          quantity: 1,
          price: price,
          #price: price,

        }]
      )

      redirect_to session.url, allow_other_host: true
  end

  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @customer = Stripe::Customer.retrieve(session.customer)
  end

  # def retrieve_price_id
  #   # price=Stripe::Price.search({
  #   #   query: 'active:\'true\' AND metadata[\'order_id\']:\'6735\'',
  #   # }).data[9]
  #   p=Plan.new
  #   puts p.return_price_id
  #   puts "checking price"
  # end

end
