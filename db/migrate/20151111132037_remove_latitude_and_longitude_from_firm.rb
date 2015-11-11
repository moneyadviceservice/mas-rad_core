class RemoveLatitudeAndLongitudeFromFirm < ActiveRecord::Migration
  class Firm < ActiveRecord::Base
    has_many :offices, -> { order created_at: :asc }
    scope :geocoded, -> { where.not(latitude: nil, longitude: nil) }

    def main_office
      offices.first
    end
  end

  class Office < ActiveRecord::Base
    belongs_to :firm

    def geocoded?
      latitude.present? && longitude.present?
    end
  end

  def up
    migrate_firm_coords_to_main_office

    remove_column :firms, :latitude
    remove_column :firms, :longitude

    index_warning
  end

  def down
    add_column :firms, :latitude, :float
    add_column :firms, :longitude, :float

    migrate_main_office_coords_to_firm

    index_warning
  end

  private

  def migrate_firm_coords_to_main_office
    update_count = 0

    Firm.geocoded.includes(:offices).find_each do |f|
      next unless f.offices.present?

      f.main_office.update!(latitude: f.latitude,
                            longitude: f.longitude)

      update_count += 1
    end

    say "Migrated #{update_count} coordinates to main offices"
  end

  def migrate_main_office_coords_to_firm
    update_count = 0
    Firm.includes(:offices).find_each do |f|
      next unless f.offices.present?
      next unless f.main_office.geocoded?

      f.update!(latitude: f.main_office.latitude,
                longitude: f.main_office.longitude)

      update_count += 1
    end

    say "Migrated #{update_count} coordinates to back to firms"
  end

  def index_warning
    say '(!!) Changes have been made that require reindexing (run: rake firms:index)'
  end
end
