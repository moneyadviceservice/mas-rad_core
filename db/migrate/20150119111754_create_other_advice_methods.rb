class CreateOtherAdviceMethods < ActiveRecord::Migration
  def change
    create_table :other_advice_methods do |t|
      t.string :name, null: false, unique: true

      t.timestamps null: false
    end

    create_join_table :firms, :other_advice_methods do |t|
      t.index %i(firm_id other_advice_method_id),
        name: 'firms_other_advice_methods_index',
        unique: true
    end
  end
end
