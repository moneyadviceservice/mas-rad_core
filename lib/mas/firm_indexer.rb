module FirmIndexer
  def self.index_firm(firm)
    if firm.publishable?
      store_firm(firm)
    else
      delete_firm(firm)
    end
  end

  def self.handle_firm_changed(firm)
    return delete_firm(firm) if firm.destroyed?
    index_firm(firm)
  end

  def self.store_firm(firm)
    FirmRepository.new.store(firm)
  end

  def self.delete_firm(firm)
    FirmRepository.new.delete(firm.id)
  end
end
