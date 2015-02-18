class GeocodeFirmJob < ActiveJob::Base
  def perform(firm)
    results = Geocoder.search(firm.full_street_address)

    if results.any?
      Stats.increment('radsignup.geocode.firm.success')

      firm.latitude = results.first.latitude
      firm.longitude = results.first.longitude
      firm.save(callbacks: false)
    else
      Stats.increment('radsignup.geocode.firm.failed')

      firm.latitude = nil
      firm.longitude = nil
      firm.save(callbacks: false)
    end
  end
end
