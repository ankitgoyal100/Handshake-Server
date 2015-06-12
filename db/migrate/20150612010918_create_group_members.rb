class CreateGroupMembers < ActiveRecord::Migration
  def change
    create_table :group_members do |t|
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
    
    add_index :group_members, :user_id
    add_index :group_members, :group_id
  end
end
