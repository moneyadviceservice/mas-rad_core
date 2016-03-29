class AddAddNonUkResidentsToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :firms_providing_non_uk_residents, :integer, default: 0
  end
end
