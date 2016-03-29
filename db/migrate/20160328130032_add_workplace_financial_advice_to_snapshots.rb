class AddWorkplaceFinancialAdviceToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :firms_providing_workplace_financial_advice, :integer, default: 0
  end
end
