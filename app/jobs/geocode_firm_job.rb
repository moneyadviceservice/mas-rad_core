class GeocodeFirmJob < ActiveJob::Base
  def perform(firm)
    results = Geocoder.search(firm.full_street_address)

    if results.any?
      Stats.increment('radsignup.geocode.firm.success')
      firm.geocode!(results.first.latitude, results.first.longitude)
    else
      Stats.increment('radsignup.geocode.firm.failed')
      firm.geocode!(nil, nil)
    end
  end
end
