class AddWebsiteToOffice < ActiveRecord::Migration
  def change
    add_column :offices, :website, :string
  end
end
