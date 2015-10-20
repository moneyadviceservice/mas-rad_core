require 'uk_phone_numbers'

class FirmResult
  PERCENTAGE_FOR_TRUE = 100

  LESS_THAN_FIFTY_K_ID = 1

  DIRECTLY_MAPPED_FIELDS = [
    :address_line_one,
    :address_line_two,
    :address_town,
    :address_county,
    :address_postcode,
    :website_address,
    :email_address,
    :free_initial_meeting,
    :minimum_fixed_fee,
    :other_advice_methods,
    :in_person_advice_methods,
    :investment_sizes,
    :adviser_accreditation_ids,
    :adviser_qualification_ids
  ]

  TYPES_OF_ADVICE_FIELDS = [
    :retirement_income_products,
    :pension_transfer,
    :options_when_paying_for_care,
    :equity_release,
    :inheritance_tax_planning,
    :wills_and_probate
  ]

  attr_reader :id,
    :name,
    :total_advisers,
    *DIRECTLY_MAPPED_FIELDS,
    *TYPES_OF_ADVICE_FIELDS

  def initialize(data)
    source = data['_source']
    @id    = source['_id']
    @name  = source['registered_name']
    @advisers         = source['advisers']
    @total_advisers   = source['advisers'].count
    @closest_adviser  = data['sort'].first
    @telephone_number = source['telephone_number']

    (DIRECTLY_MAPPED_FIELDS + TYPES_OF_ADVICE_FIELDS).each do |field|
      instance_variable_set("@#{field}", source[field.to_s])
    end
  end

  def advisers
    @advisers.map { |adviser_data| AdviserResult.new(adviser_data) }
  end

  def includes_advice_type?(advice_type)
    public_send(advice_type) == PERCENTAGE_FOR_TRUE
  end

  def types_of_advice
    TYPES_OF_ADVICE_FIELDS.select { |field| public_send(field).nonzero? }
  end

  def minimum_fixed_fee?
    minimum_fixed_fee && minimum_fixed_fee.nonzero?
  end

  def minimum_pot_size_id
    investment_sizes.first
  end

  def minimum_pot_size?
    minimum_pot_size_id > LESS_THAN_FIFTY_K_ID
  end

  def closest_adviser
    if @closest_adviser < 1
      I18n.t('search.result.miles_away_alt')
    else
      "#{format('%.1f', @closest_adviser)} #{I18n.t('search.result.miles_away')}"
    end
  end

  def telephone_number
    return nil unless @telephone_number

    UKPhoneNumbers.format(@telephone_number)
  end

  alias :free_initial_meeting? :free_initial_meeting
end
