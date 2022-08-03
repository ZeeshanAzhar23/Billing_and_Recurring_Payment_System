module FeaturesHelper
  def find_usage
    @feature=Feature.find(params[:id])
    @plan=@feature.plan
    @subscription=Subscription.find_by(plan_id: @plan.id,user_id:current_user.id)
    @feature_usage=FeatureUsage.find_by(subscription_id:@subscription.id,feature_id:@feature.id)
    @feature_usage
  end
  def decide
    @feature_usage=find_usage
    if @feature_usage != nil
      @url= feature_feature_usage_path(params[:id])
      @method= 'put'
      @feature_usage.usage_value
    else
      @url = feature_feature_usages_path(params[:id])
      @method = 'post'
    end

  end
end
