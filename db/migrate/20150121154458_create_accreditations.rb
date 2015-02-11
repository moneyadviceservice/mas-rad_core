class CreateAccreditations < ActiveRecord::Migration
  def change
    create_table :accreditations do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_join_table :advisers, :accreditations do |t|
      t.index %i(adviser_id accreditation_id),
        unique: true,
        name: 'advisers_accreditations_index'
    end
  end
end
