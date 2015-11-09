module FirmIndexer
  class << self
    def index_firm(firm)
      if !firm.destroyed? && firm.publishable?
        store_firm(firm)
      else
        delete_firm(firm)
      end
    end

    alias_method :handle_firm_changed, :index_firm

    def handle_aggregate_changed(aggregate)
      index_firm(aggregate.firm) if firm_exists?(aggregate.firm)
    end

    def firm_exists?(firm)
      return false if (firm.nil? || firm.destroyed?)
      Firm.exists?(firm.id)
    end

    private

    def store_firm(firm)
      FirmRepository.new.store(firm)
    end

    def delete_firm(firm)
      FirmRepository.new.delete(firm.id)
    end
  end
end
