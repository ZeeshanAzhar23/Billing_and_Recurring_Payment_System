module UsersHelper
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  #delete customer from stripe if user choses to delete his acc from app
  def delete_stripe_customer
    @cust_id=@user.customer_id
    yield
    Stripe::Customer.delete(@cust_id)
  end

end
