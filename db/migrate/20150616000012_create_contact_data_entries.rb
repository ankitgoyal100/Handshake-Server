class CreateContactDataEntries < ActiveRecord::Migration
  def change
    create_table :contact_data_entries do |t|
      t.string :phone
      t.string :email
      
      t.timestamps
    end
    
    add_index :contact_data_entries, :phone
    add_index :contact_data_entries, :email
  end
end
