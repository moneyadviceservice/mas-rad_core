# Moving address to a main office. Please note that email and telephone number
# are remaining on Firm, however we seed the main office with the firm's
# email address and telephone number to start with.
class MoveFirmAddressToOffice < ActiveRecord::Migration
  class Firm < ActiveRecord::Base; has_many :offices; end
  class Office < ActiveRecord::Base; belongs_to :firm; end

  def up
    Firm.where.not(address_line_one: nil).each do |firm|
      next if firm.offices.any?

      firm.offices.create!(
        address_line_one: firm.address_line_one,
        address_line_two: firm.address_line_two,
        address_town: firm.address_town,
        address_county: firm.address_county,
        address_postcode: firm.address_postcode,
        email_address: firm.email_address,
        telephone_number: firm.telephone_number
      )
    end

    remove_column :firms, :address_line_one
    remove_column :firms, :address_line_two
    remove_column :firms, :address_town
    remove_column :firms, :address_county
    remove_column :firms, :address_postcode
  end

  def down
    add_column :firms, :address_line_one, :string
    add_column :firms, :address_line_two, :string
    add_column :firms, :address_town,     :string
    add_column :firms, :address_county,   :string
    add_column :firms, :address_postcode, :string

    Firm.all.select { |f| f.offices.any? }.each do |firm|
      main_office = firm.offices.first
      firm.update!(
        address_line_one: main_office.address_line_one,
        address_line_two: main_office.address_line_two,
        address_town: main_office.address_town,
        address_county: main_office.address_county,
        address_postcode: main_office.address_postcode
      )
    end
  end
end
