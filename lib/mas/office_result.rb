class OfficeResult
  attr_reader :id, :address_line_one, :address_line_two, :address_town,
              :address_county, :address_postcode, :email_address,
              :telephone_number, :disabled_access, :location, :website

  attr_accessor :distance

  def initialize(data)
    @id               = data['_id']
    @address_line_one = data['address_line_one']
    @address_line_two = data['address_line_two']
    @address_town     = data['address_town']
    @address_county   = data['address_county']
    @address_postcode = data['address_postcode']
    @email_address    = data['email_address']
    @telephone_number = data['telephone_number']
    @disabled_access  = data['disabled_access']
    @location = Location.new data['location']['lat'], data['location']['lon']
    @website          = data['website']
  end
end
