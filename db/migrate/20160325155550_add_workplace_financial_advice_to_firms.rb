class AddWorkplaceFinancialAdviceToFirms < ActiveRecord::Migration
  def change
    add_column :firms, :workplace_financial_advice_flag, :boolean, default: false, null: false
  end
end
