class DeleteTypeFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :user_type
  end
end
