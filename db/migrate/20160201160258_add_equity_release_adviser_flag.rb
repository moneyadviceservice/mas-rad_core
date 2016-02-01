class AddEquityReleaseAdviserFlag < ActiveRecord::Migration
  def change
    add_column :advisers, :equity_release_adviser, :bool, default: false
  end
end
