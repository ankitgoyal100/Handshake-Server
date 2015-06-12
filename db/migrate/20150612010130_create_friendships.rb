class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :contact_id
      t.boolean :accepted
      t.boolean :is_deleted

      t.timestamps
    end
    
    add_index :friendships, :user_id
    add_index :friendships, :contact_id
    add_index :friendships, [:user_id, :contact_id]
    
    add_index :friendships, [:user_id, :accepted]
    add_index :friendships, [:contact_id, :accepted]
    
    add_index :friendships, [:user_id, :is_deleted]
    add_index :friendships, [:contact_id, :is_deleted]
  end
end
