class AddIndexesToPhonesAndEmails < ActiveRecord::Migration
  def change
    add_index :phones, :number
    add_index :emails, :address
  end
end
