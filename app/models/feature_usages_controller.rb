class FeatureUsagesController < ApplicationController
  before_action :find_usage, only: [:update]
  def create
    # @plan=Plan.find(params[:plan_id])
    @user=User.find(current_user.id)
    @feature=Feature.find(params[:feature_id])
    @plan=Plan.find_by(id: @feature.plan_id)
    @subscription = Subscription.find_by(user_id:@user.id , plan_id:@plan.id)
    @feature_usage=FeatureUsage.new(
      subscription_id: @subscription.id,
      feature_id: @feature.id,
      usage_value: params[:usage_value]
    )
    if unit_limit_constraint?
      if @feature_usage.save
        redirect_to plan_features_path(@plan)
      else
        flash[:alert] = 'Value can only be in numbers'
        redirect_to request.referer
      end
    else
      flash[:alert] = 'Out of Range Value'
      redirect_to request.referer
    end
  end
  def update
    if unit_limit_constraint?
      if @feature_usage.update!(usage_params)
        redirect_to plan_features_path(@plan)
      else
        flash[:alert] = 'Value can only be in numbers'
        redirect_to request.referer
      end
    else
      flash[:alert] = 'Out of Range Value'
      redirect_to request.referer
    end
  end
  private
  def usage_params
    params.require(:feature_usage).permit(:usage_value)
  end
  def find_usage
    puts params[:plan_id]
    @feature=Feature.find(params[:id])
    @plan=@feature.plan
    @subscription=Subscription.find_by(plan_id: @plan.id,user_id:current_user.id)
    @feature_usage=FeatureUsage.find_by(subscription_id:@subscription.id,feature_id:@feature.id)
    @feature_usage
  end
  def unit_limit_constraint?
    if @feature.max_unit_limit >= @feature_usage.usage_value.to_i
      true
    else
      false
    end
  end
end
