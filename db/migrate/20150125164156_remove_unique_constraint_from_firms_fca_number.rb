class RemoveUniqueConstraintFromFirmsFcaNumber < ActiveRecord::Migration
  def change
    remove_index :firms, :fca_number
  end
end
