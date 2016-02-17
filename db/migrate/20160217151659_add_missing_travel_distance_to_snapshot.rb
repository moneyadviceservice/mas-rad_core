class AddMissingTravelDistanceToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :advisers_who_travel_200_miles, :integer
  end
end
