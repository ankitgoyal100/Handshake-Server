class CreateNotificationsSettings < ActiveRecord::Migration
  def change
    create_table :notifications_settings do |t|
      t.integer :user_id
      
      t.boolean :enabled
      
      t.boolean :requests
      t.boolean :new_contacts
      t.boolean :new_group_members
      t.boolean :new_contact_information
      t.boolean :contact_joined
      t.boolean :suggestions
      t.boolean :new_features
      t.boolean :offers

      t.timestamps
    end
    
    add_index :notifications_settings, :user_id
  end
end
