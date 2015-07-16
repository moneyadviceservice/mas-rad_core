class RemoveOtherFlagFromFirms < ActiveRecord::Migration
  def change
    remove_column :firms, :other_flag, :string
  end
end
