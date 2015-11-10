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
      # This method may be invoked as part of a cascade delete, in which case
      # we should do nothing here. The firm change notification will handle
      # the change.
      return if associated_firm_destroyed?(aggregate)
      index_firm(aggregate.firm)
    end

    def associated_firm_destroyed?(aggregate)
      firm = aggregate.firm
      return true if (firm.nil? || firm.destroyed?)
      !Firm.exists?(firm.id)
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
