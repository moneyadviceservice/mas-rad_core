class RemoveCoversWholeOfUkFromAdvisers < ActiveRecord::Migration
  WHOLE_OF_UK_MILES = 650

  def up
    Adviser.where(covers_whole_of_uk: true).find_each do |adviser|
      adviser.postcode = adviser.firm.address_postcode
      adviser.travel_distance = WHOLE_OF_UK_MILES
      adviser.save!
    end

    remove_column :advisers, :covers_whole_of_uk
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
