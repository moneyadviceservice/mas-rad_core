class GeocodeFirmJob < ActiveJob::Base
  def perform(firm)
    Geocoder.coordinates(firm.full_street_address).tap do |coordinates|
      firm.geocode!(coordinates)

      if coordinates
        IndexFirmJob.perform_later(firm)
        stat :success
      else
        stat :failed
      end
    end
  end

  private

  def stat(key)
    Stats.increment("radsignup.geocode.firm.#{key}")
  end
end
