class CreateInPersonAdviceMethods < ActiveRecord::Migration
  def change
    create_table :in_person_advice_methods do |t|
      t.string :name, null: false, unique: true

      t.timestamps null: false
    end

    create_join_table :firms, :in_person_advice_methods do |t|
      t.index %i(firm_id in_person_advice_method_id),
        name: 'firms_in_person_advice_methods_index',
        unique: true
    end
  end
end
