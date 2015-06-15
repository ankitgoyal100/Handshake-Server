class AddCountryCodeToPhones < ActiveRecord::Migration
  def change
    add_column :phones, :country_code, :string
  end
end
