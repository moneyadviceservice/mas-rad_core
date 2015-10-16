class GeocodeFirmJob < ActiveJob::Base
  def perform(firm)
    if ModelGeocoder.geocode!(firm)
      IndexFirmJob.perform_later(firm)
      stat :success
    else
      stat :failed
    end
  end

  private

  def stat(key)
    Stats.increment("radsignup.geocode.firm.#{key}")
  end
end
