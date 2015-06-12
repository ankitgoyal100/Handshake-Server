class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :address
      t.string :label
      t.integer :card_id

      t.timestamps
    end
    
    add_index :emails, :card_id
  end
end
