class CreateBlackListeds < ActiveRecord::Migration
  def change
    create_table :black_listeds do |t|
      t.integer :user_id
      t.integer :black_listed_user_id

      t.timestamps
    end
    
    add_index :black_listeds, :user_id
    add_index :black_listeds, :black_listed_user_id
  end
end
