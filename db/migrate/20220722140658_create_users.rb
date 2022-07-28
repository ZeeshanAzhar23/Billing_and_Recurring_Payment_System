class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password
      t.integer :type, :default => 0
      #Ex:- :default =>''
      t.timestamps
    end
  end
end
