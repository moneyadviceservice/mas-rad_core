class RenameSubsidiariesToTradingNames < ActiveRecord::Migration
  def change
    rename_table :lookup_subsidiaries, :lookup_trading_names
  end
end
