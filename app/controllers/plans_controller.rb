class PlansController < ApplicationController
  before_action :find_plan, only: [:show,:edit,:update,:destroy]
  around_action :delete_plan, only: [:destroy]
  def index
  @plans=Plan.all
  authorize @plans
  end

  def new
    @plan=Plan.new
    authorize @plan
  end
  def create
    @plan=Plan.create(plan_params)
    authorize @plan
    if @plan.save
      redirect_to plans_path
    else
      render 'new'
    end
  end
  def edit
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
    @features = Plan.find(params[:id]).features.new
  end

  def destroy
    if @plan.destroy
      redirect_to plans_path
    end
  end

  private def plan_params
    params.require(:plan).permit(:name,:monthly_fee)
  end

  private def find_plan
    @plan = Plan.find(params[:id])
  end
  private def delete_plan
    @stripe_prod_id=@plan.stripe_plan_id
    @stripe_price_id=@plan.price_id
    yield
    #Strip::Price.delete(@stripe_price_id)
    Stripe::Product.update(@stripe_prod_id,active: 'false')
  end

end
