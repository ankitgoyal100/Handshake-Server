class CreateFeedItems < ActiveRecord::Migration
  def change
    create_table :feed_items do |t|
      t.integer :user_id
      t.integer :contact_id
      t.integer :group_id
      t.string :item_type

      t.timestamps
    end
    
    add_index :feed_items, :user_id
    add_index :feed_items, :contact_id
    add_index :feed_items, :group_id
    
    add_index :feed_items, [:user_id, :contact_id, :group_id]
    add_index :feed_items, [:user_id, :contact_id]
    add_index :feed_items, [:user_id, :group_id]
  end
end
