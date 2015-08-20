class AddStatusToFirms < ActiveRecord::Migration
  def change
    add_column :firms, :status, :integer
  end
end
