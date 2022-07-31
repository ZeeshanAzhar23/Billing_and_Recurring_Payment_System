class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.references :plan, foreign_key: true
      t.string :stripe_plan_id
      t.string :stripe_customer_id
      t.string :status
      t.string :interval
      t.string :subscription_id
      t.datetime :current_period_start
      t.datetime :current_period_end

      t.timestamps
    end
  end
end
