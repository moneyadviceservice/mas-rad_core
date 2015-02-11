class AddAddressToFirm < ActiveRecord::Migration
  def change
    add_column :firms, :address_line_one, :string
    add_column :firms, :address_line_two, :string
    add_column :firms, :address_town, :string
    add_column :firms, :address_county, :string
    add_column :firms, :address_postcode, :string
  end
end
