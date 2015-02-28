class AddCyNameToOtherAdviceMethods < ActiveRecord::Migration
  def change
    add_column :other_advice_methods, :cy_name, :string
  end
end
