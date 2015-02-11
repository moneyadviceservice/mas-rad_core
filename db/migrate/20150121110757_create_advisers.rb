class CreateAdvisers < ActiveRecord::Migration
  def change
    create_table :advisers do |t|
      t.string :reference_number, null: false, unique: true, length: 8
      t.string :name, null: false
      t.belongs_to :firm, null: false

      t.timestamps null: false
    end
  end
end
