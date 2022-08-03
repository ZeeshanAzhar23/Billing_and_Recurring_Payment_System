class AddStripePlanIdToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :stripe_plan_id, :string
  end
end
