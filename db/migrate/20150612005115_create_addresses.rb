class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :label
      t.integer :card_id

      t.timestamps
    end
    
    add_index :addresses, :card_id
  end
end
