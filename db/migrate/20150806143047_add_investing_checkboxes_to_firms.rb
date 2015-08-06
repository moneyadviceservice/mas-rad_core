class AddInvestingCheckboxesToFirms < ActiveRecord::Migration
  def change
    add_column :firms, :ethical_investing_flag, :boolean, default: false, null: false
    add_column :firms, :sharia_investing_flag, :boolean, default: false, null: false
  end
end
