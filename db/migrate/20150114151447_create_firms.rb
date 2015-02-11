class CreateFirms < ActiveRecord::Migration
  def change
    create_table :firms do |t|
      t.integer :fca_number, null: false
      t.string :registered_name, null: false
      t.string :email_address
      t.string :telephone_number
      t.index :fca_number, unique: true

      t.timestamps null: false
    end
  end
end
