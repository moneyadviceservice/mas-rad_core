class CreateInitialAdviceFeeStructures < ActiveRecord::Migration
  def change
    create_table :initial_advice_fee_structures do |t|
      t.string :name, null: false, unique: true

      t.timestamps null: false
    end

    create_join_table :firms, :initial_advice_fee_structures do |t|
      t.index %i(firm_id initial_advice_fee_structure_id),
        name: 'firms_initial_advice_fee_structures_index',
        unique: true
    end
  end
end
