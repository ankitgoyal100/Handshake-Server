class CreateCardsGroupMembers < ActiveRecord::Migration
  def change
    create_table :cards_group_members, index: false do |t|
      t.references :card
      t.references :group_member
    end
    
    add_index :cards_group_members, [:card_id, :group_member_id]
    add_index :cards_group_members, :card_id
    add_index :cards_group_members, :group_member_id
  end
end
