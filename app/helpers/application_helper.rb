module ApplicationHelper
  def subed_to_current_plan?(plan,user)
    Subscription.where(plan_id: plan.id, user_id:user.id).present?
  end
  def find_subscribed_plans(user)
    @subbed_plans = Array.new()
    @subscriptions=Subscription.where(user_id:user.id)
    @subscriptions.each do |subscription|
      @subbed_plans.push(Plan.find_by(id: subscription.plan_id))
    end
    @subbed_plans
  end
end
