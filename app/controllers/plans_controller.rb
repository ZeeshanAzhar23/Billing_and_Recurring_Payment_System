# frozen_string_literal: true
class PlansController < ApplicationController
  before_action :find_plan, only: %i[show edit update destroy]
  around_action :delete_plan, only: :destroy
  # after_action :update_plan, only: :update
  def index
    @plans = Plan.all
    authorize @plans
  end
  def new
    @plan = Plan.new
    authorize @plan
    @disable = false
  end
  def create
    @plan = Plan.create(plan_params)
    authorize @plan
    if @plan.save
      redirect_to plans_path
    else
      render 'new'
    end
  end
  def edit
    @disable = true
    authorize @plan
  end

  def update
    authorize @plan
    if @plan.update(plan_params)
      redirect_to plan_path(@plan)
    else
      render 'edit'
    end
  end
  def show
    @features = @plan.features.new
  end
  def destroy
    redirect_to plans_path if @plan.destroy
  end
  private
  def plan_params
    params.require(:plan).permit(:name, :monthly_fee)
  end
  def find_plan
    @plan = Plan.find(params[:id])
  end
  def delete_plan
    @stripe_prod_id = @plan.stripe_plan_id
    @stripe_price_id = @plan.price_id
    yield
    Stripe::Product.update(@stripe_prod_id, active: 'false')
  end
end
