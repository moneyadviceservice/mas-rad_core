class CreateProfessionalBodies < ActiveRecord::Migration
  def change
    create_table :professional_bodies do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_join_table :advisers, :professional_bodies do |t|
      t.index %i(adviser_id professional_body_id),
        unique: true,
        name: 'advisers_professional_bodies_index'
    end
  end
end
