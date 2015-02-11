class AddGeographicalFieldsToAdviser < ActiveRecord::Migration
  def change
    add_column :advisers, :postcode, :string, null: false, default: ''
    add_column :advisers, :travel_distance, :integer, null: false, default: 0
    add_column :advisers, :covers_whole_of_uk, :boolean, null: false, default: false
  end
end
