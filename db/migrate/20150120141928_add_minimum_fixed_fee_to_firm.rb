class AddMinimumFixedFeeToFirm < ActiveRecord::Migration
  def change
    add_column :firms, :minimum_fixed_fee, :integer
  end
end
