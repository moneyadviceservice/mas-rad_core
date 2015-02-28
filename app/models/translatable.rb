module Translatable
  alias_attribute :en_name, :name

  def localized_name
    case I18n.locale
    when :en
      en_name
    when :cy
      cy_name
    end
  end
end
