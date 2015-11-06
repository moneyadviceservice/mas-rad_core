module FirmIndexer
  def self.index_firm(firm)
    repo = FirmRepository.new

    if firm.publishable?
      repo.store(firm)
    else
      repo.delete(firm.id)
    end
  end
end
