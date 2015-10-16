class GeocodeAdviserJob < ActiveJob::Base
  def perform(adviser)
    if ModelGeocoder.geocode!(adviser)
      IndexFirmJob.perform_later(adviser.firm)
      stat :success
    else
      stat :failed
    end
  end

  private

  def stat(key)
    Stats.increment("radsignup.geocode.adviser.#{key}")
  end
end
