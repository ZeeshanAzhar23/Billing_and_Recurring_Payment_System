class RemoveTypeFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :type
  end
end
