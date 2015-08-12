class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.string :address_line_one, null: false
      t.string :address_line_two
      t.string :address_town, null: false
      t.string :address_county
      t.string :address_postcode, null: false
      t.string :email_address
      t.string :telephone_number
      t.boolean :disabled_access, default: false, null: false

      t.belongs_to :firm, null: false

      t.timestamps null: false
    end
  end
end
