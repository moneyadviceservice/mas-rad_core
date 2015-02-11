class CreateLookupSubsidiaries < ActiveRecord::Migration
  def change
    create_table :lookup_subsidiaries do |t|
      t.integer :fca_number, null: false, index: true
      t.string  :name, null: false, default: ''

      t.timestamps null: false
    end
  end
end
