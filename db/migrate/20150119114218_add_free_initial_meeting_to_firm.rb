class AddFreeInitialMeetingToFirm < ActiveRecord::Migration
  def change
    add_column :firms, :free_initial_meeting, :boolean
  end
end
