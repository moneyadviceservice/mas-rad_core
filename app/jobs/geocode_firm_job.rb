require 'geocoder'

class GeocodeFirmJob < ActiveJob::Base
  def perform(firm)
    results = Geocoder.search(firm.full_street_address)

    if results.any?
      stat :success
      firm.geocode!(results.first.latitude, results.first.longitude)
    else
      stat :failed
      firm.geocode!
    end
  end

  private

  def stat(key)
    Stats.increment("radsignup.geocode_firm.#{key}")
  end
end
