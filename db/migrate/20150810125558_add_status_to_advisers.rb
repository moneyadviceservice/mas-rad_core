class AddStatusToAdvisers < ActiveRecord::Migration
  def change
    add_column :advisers, :status, :integer
  end
end
