class AddNonUkResidentsToFirms < ActiveRecord::Migration
  def change
    add_column :firms, :non_uk_residents_flag, :boolean, default: false, null: false
  end
end
