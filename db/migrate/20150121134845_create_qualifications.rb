class CreateQualifications < ActiveRecord::Migration
  def change
    create_table :qualifications do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_join_table :advisers, :qualifications do |t|
      t.index %i(adviser_id qualification_id),
        unique: true,
        name: 'advisers_qualifications_index'
    end
  end
end
