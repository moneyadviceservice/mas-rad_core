module Translatable
  def en_name
    self.name
  end

  def localized_name
    case I18n.locale
      when :en
        en_name
      when :cy
        cy_name
    end || name
  end
end
