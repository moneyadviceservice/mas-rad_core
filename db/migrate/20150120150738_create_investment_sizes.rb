class CreateInvestmentSizes < ActiveRecord::Migration
  def change
    create_table :investment_sizes do |t|
      t.string :name, null: false, unique: true

      t.timestamps null: false
    end

    create_join_table :firms, :investment_sizes do |t|
      t.index %i(firm_id investment_size_id),
        name: 'firms_investment_sizes_index',
        unique: true
    end
  end
end
