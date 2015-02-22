class AddLatitudeAndLongitudeToAdvisers < ActiveRecord::Migration
  def change
    add_column :advisers, :latitude, :float
    add_column :advisers, :longitude, :float
  end
end
