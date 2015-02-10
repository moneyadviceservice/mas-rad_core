class AddLatitudeAndLongitudeToFirm < ActiveRecord::Migration
  def change
    add_column :firms, :latitude, :float
    add_column :firms, :longitude, :float
  end
end
