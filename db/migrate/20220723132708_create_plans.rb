class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.string :name
      t.decimal :monthly_fee, precision: 10, scale: 2

      t.timestamps
    end
  end
end
