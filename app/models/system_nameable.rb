module SystemNameable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def system_name(id)
      order = find(id).order
      self::SYSTEM_NAMES.fetch(order, :not_found)
    end
  end
end
