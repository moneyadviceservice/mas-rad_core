class CreateProfessionalStandings < ActiveRecord::Migration
  def change
    create_table :professional_standings do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_join_table :advisers, :professional_standings do |t|
      t.index %i(adviser_id professional_standing_id),
        unique: true,
        name: 'advisers_professional_standings_index'
    end
  end
end
