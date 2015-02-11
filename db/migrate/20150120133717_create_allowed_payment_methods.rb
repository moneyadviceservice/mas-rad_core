class CreateAllowedPaymentMethods < ActiveRecord::Migration
  def change
    create_table :allowed_payment_methods do |t|
      t.string :name, null: false, unique: true

      t.timestamps null: false
    end

    create_join_table :firms, :allowed_payment_methods do |t|
      t.index %i(firm_id allowed_payment_method_id),
        name: 'firms_allowed_payment_methods_index',
        unique: true
    end
  end
end
