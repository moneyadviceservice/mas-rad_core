class CreateOngoingAdviceFeeStructures < ActiveRecord::Migration
  def change
    create_table :ongoing_advice_fee_structures do |t|
      t.string :name, null: false, unique: true

      t.timestamps null: false
    end

    create_join_table :firms, :ongoing_advice_fee_structures do |t|
      t.index %i(firm_id ongoing_advice_fee_structure_id),
        name: 'firms_ongoing_advice_fee_structures_index',
        unique: true
    end
  end
end
