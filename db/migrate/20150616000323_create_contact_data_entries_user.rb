class CreateContactDataEntriesUser < ActiveRecord::Migration
  def change
    create_table :contact_data_entries_users, index: false do |t|
      t.references :contact_data_entry
      t.references :user
    end
    
    add_index :contact_data_entries_users, :contact_data_entry_id
    add_index :contact_data_entries_users, :user_id
  end
end
