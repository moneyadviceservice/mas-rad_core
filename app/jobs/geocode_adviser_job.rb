require 'geocoder'

class GeocodeAdviserJob < ActiveJob::Base
  def perform(adviser)
    coordinates = Geocoder.coordinates(adviser.full_street_address)
    coordinates ? stat(:success) : stat(:failed)
    adviser.geocode!(coordinates)
  end

  private

  def stat(key)
    Stats.increment("radsignup.geocode.adviser.#{key}")
  end
end
