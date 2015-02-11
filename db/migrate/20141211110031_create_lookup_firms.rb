class CreateLookupFirms < ActiveRecord::Migration
  def change
    create_table :lookup_firms do |t|
      t.integer :fca_number, null: false
      t.string  :registered_name, null: false, default: ''
      t.index   :fca_number, unique: true

      t.timestamps
    end
  end
end
