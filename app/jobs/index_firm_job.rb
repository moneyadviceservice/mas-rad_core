class IndexFirmJob < ActiveJob::Base
  around_perform do |job, block|
    Stats.time 'radsignup.index.firm', &block
  end

  def perform(firm)
    FirmIndexer.index_firm(firm)
  end
end
