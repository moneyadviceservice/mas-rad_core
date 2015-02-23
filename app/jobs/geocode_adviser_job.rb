require 'geocoder'

class GeocodeAdviserJob < ActiveJob::Base
  def perform(adviser)
    point = Geocoder.coordinates(adviser.full_street_address)
    point ? stat(:success) : stat(:failed)
    adviser.geocode!(point)
  end

  private

  def stat(key)
    Stats.increment("radsignup.geocode_adviser.#{key}")
  end
end
