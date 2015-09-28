class IndexFirmJob < ActiveJob::Base
  around_perform do |job, block|
    Stats.time 'radsignup.index.firm', &block
  end

  def perform(firm)
    if firm.publishable?
      FirmRepository.new.store(firm)
    else
      DeleteFirmJob.perform_later(firm.id)
    end
  end
end
