class CreateFeatureUsages < ActiveRecord::Migration[5.2]
  def change
    create_table :feature_usages do |t|
      t.decimal :usage_value
      t.references :subscription, foreign_key: true
      t.references :feature, foreign_key: true

      t.timestamps
    end
  end
end
