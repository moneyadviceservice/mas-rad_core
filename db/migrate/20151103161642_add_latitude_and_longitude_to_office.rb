class AddLatitudeAndLongitudeToOffice < ActiveRecord::Migration
  def change
    add_column :offices, :latitude, :float
    add_column :offices, :longitude, :float
  end
end
