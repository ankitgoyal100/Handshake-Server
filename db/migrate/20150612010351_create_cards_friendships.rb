class CreateCardsFriendships < ActiveRecord::Migration
  def change
    create_table :cards_friendships, index: false do |t|
      t.references :card
      t.references :friendship
    end
    
    add_index :cards_friendships, [:card_id, :friendship_id]
    add_index :cards_friendships, :card_id
    add_index :cards_friendships, :friendship_id
  end
end
