class CreateFeatures < ActiveRecord::Migration[5.2]
  def change
    create_table :features do |t|
      t.references :plan, foreign_key: true
      t.string :name
      t.decimal :code, precision: 10, scale: 2
      t.decimal :unit_price, precision: 10, scale: 2
      t.integer :max_unit_limit

      t.timestamps
    end
  end
end
