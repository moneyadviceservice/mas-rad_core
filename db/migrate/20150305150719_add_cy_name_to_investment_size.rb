class AddCyNameToInvestmentSize < ActiveRecord::Migration
  def up
    add_column :investment_sizes, :cy_name, :string

    mapping = {
      'Under £50,000' => 'Dan £50,000',
      '£50,000 - £99,999' => '£50,000 - £99,999',
      '£100,000 - £149,999' => '£100,000 - £149,999',
      'Over £150,000' => 'Dros £150,000'
    }

    InvestmentSize.all.each do |investment_size|
      investment_size.update!(cy_name: mapping[investment_size.name])
    end
  end

  def down
    remove_column :investment_sizes, :cy_name
  end
end
