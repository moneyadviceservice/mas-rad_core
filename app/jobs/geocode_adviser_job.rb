class GeocodeAdviserJob < ActiveJob::Base
  def perform(adviser)
    Geocoder.coordinates(adviser.full_street_address).tap do |coords|
      adviser.geocode!(coords)

      if coords
        IndexFirmJob.perform_later(adviser.firm)
        stat :success
      else
        stat :failed
      end
    end
  end

  private

  def stat(key)
    Stats.increment("radsignup.geocode.adviser.#{key}")
  end
end
