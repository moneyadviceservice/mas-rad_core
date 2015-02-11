class CreateLookupAdvisers < ActiveRecord::Migration
  def change
    create_table :lookup_advisers do |t|
      t.string :reference_number, null: false, unique: true, length: 8
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
