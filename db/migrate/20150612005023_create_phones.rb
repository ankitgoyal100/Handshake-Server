class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.string :number
      t.string :label
      t.integer :card_id

      t.timestamps
    end
    
    add_index :phones, :card_id
  end
end
