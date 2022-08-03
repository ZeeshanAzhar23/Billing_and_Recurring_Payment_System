# frozen_string_literal: true
class UsersController < ApplicationController
  before_action :find_user, only: %i[show destroy edit update]
  around_action :delete_stripe_customer, only: [:destroy]
  before_action :authenticate_user!
  after_action  :update_stripe_customer, only: [:update]
  def index
    @users = User.all
    authorize @users
  end
  def show; end
  def edit
    authorize @user
  end
  def update
    authorize @user
    if @user.update!(user_params)
      redirect_to @user
    else
      render 'edit'
    end
  end
  def destroy
    redirect_to users_path if @user.destroy
  end
  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :image)
  end
  def find_user
    @user = User.find(params[:id])
  end
  def authorize_admin
    return if current_user.admin?
    redirect_to root_path, alert: 'Admins only!'
  end
  def delete_stripe_customer
    @cust_id = @user.customer_id
    yield
    Stripe::Customer.delete(@cust_id)
  end
  def update_stripe_customer
    Rails.logger.debug @user.customer_id
    if @user.role == 'buyer'
      Stripe::Customer.update(
        @user.customer_id,
        email: @user.email,
        name: @user.name
      )
    end
  end
end
