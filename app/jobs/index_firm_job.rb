class IndexFirmJob < ActiveJob::Base
  def perform(firm)
    data = FirmSerializer.new(firm)
  end
end
