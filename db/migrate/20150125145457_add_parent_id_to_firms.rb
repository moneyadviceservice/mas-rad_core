class AddParentIdToFirms < ActiveRecord::Migration
  def change
    add_column :firms, :parent_id, :integer, index: true
  end
end
