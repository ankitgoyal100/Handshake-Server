class CreateBetaRequests < ActiveRecord::Migration
  def change
    create_table :beta_requests do |t|
      t.string :email
      t.string :device

      t.timestamps
    end
  end
end
