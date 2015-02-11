class CreatePrincipals < ActiveRecord::Migration
  def change
    create_table :principals do |t|
      with_options null: false do
        t.integer :fca_number, length: 6
        t.index :fca_number, unique: true

        t.string :token, length: 32
        t.index :token, unique: true

        t.string :website_address
        t.string :first_name
        t.string :last_name
        t.string :job_title
        t.string :email_address
        t.string :telephone_number
        t.boolean :confirmed_disclaimer, default: false

        t.timestamps
      end
    end
  end
end
