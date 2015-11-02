class AddDefaultValueToMinimumFixedFee < ActiveRecord::Migration
  class Firm < ActiveRecord::Base
  end

  def up
    firms = Firm.where(minimum_fixed_fee: nil)
    firms.each { |f| f.update_attribute('minimum_fixed_fee', 0) }

    change_column_default :firms, :minimum_fixed_fee, 0
  end

  def down
    change_column_default :firms, :minimum_fixed_fee, nil
  end
end
