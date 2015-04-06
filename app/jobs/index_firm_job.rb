class IndexFirmJob < ActiveJob::Base
  around_perform do |job, block|
    Stats.time 'radsignup.index.firm', &block
  end

  def perform(firm)
    FirmRepository.new.store(firm)
  end
end
