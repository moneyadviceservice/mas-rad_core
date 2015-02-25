require 'geocoder'

class GeocodeFirmJob < ActiveJob::Base
  def perform(firm)
    coordinates = Geocoder.coordinates(firm.full_street_address)
    coordinates ? stat(:success) : stat(:failed)
    firm.geocode!(coordinates)
  end

  private

  def stat(key)
    Stats.increment("radsignup.geocode_firm.#{key}")
  end
end
