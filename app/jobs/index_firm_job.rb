class IndexFirmJob < ActiveJob::Base
  def perform(firm)
    FirmRepository.new.store(firm)
  end
end
