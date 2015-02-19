class GeocodeFirmJob < ActiveJob::Base
  def perform(firm)
    results = Geocoder.search(firm.full_street_address)

    if results.present?
      Stats.increment('radsignup.geocode.firm.success')

      firm.latitude = results.first.latitude
      firm.longitude = results.first.latitude
      firm.save(callbacks: false)
    else
      Stats.increment('radsignup.geocode.firm.failed')
    end
  end
end
