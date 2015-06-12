class CreateSocials < ActiveRecord::Migration
  def change
    create_table :socials do |t|
      t.string :username
      t.string :network
      t.string :card_id

      t.timestamps
    end
    
    add_index :socials, :card_id
  end
end
