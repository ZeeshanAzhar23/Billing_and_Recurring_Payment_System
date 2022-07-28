class AddPriceIdToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :price_id, :string
  end
end
