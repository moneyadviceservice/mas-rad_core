class DeleteFirmJob < ActiveJob::Base
  around_perform do |job, block|
    Stats.time 'radsignup.delete.firm', &block
  end

  def perform(id)
    FirmRepository.new.delete(id)
  end
end
