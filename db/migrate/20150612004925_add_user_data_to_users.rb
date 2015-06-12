class AddUserDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :picture, :string
    add_column :users, :lat, :float, default: -1000
    add_column :users, :lng, :float, default: -1000
  end
end
