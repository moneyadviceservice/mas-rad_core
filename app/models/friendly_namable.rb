module FriendlyNamable
  def self.included(base)
    base.extend(ClassMethods)

    def friendly_name
      I18n.t("#{model_name.i18n_key}.ordinal.#{order}")
    end
  end

  module ClassMethods
    def friendly_name(id)
      order = find(id).order
      I18n.t("#{model_name.i18n_key}.ordinal.#{order}")
    end
  end
end
