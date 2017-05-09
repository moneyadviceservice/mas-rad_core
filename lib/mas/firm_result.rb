require 'uk_phone_numbers'

class FirmResult
  ADVICE_TYPE_NOT_SELECTED_VALUE = 0

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
    :adviser_qualification_ids,
    :ethical_investing_flag,
    :sharia_investing_flag,
    :workplace_financial_advice_flag,
    :non_uk_residents_flag,
    :languages,
    :telephone_number
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
    :total_offices,
    :closest_adviser,
    *DIRECTLY_MAPPED_FIELDS,
    *TYPES_OF_ADVICE_FIELDS

  attr_writer :closest_adviser

  def initialize(data)
    source            = data['_source']
    @id               = source['_id']
    @name             = source['registered_name']
    @advisers         = source['advisers']
    @total_advisers   = source['advisers'].count
    @closest_adviser  = data['sort'] ? data['sort'].first : 0
    @telephone_number = source['telephone_number']
    @offices          = source['offices']
    @total_offices    = source['offices'].count

    (DIRECTLY_MAPPED_FIELDS + TYPES_OF_ADVICE_FIELDS).each do |field|
      instance_variable_set("@#{field}", source[field.to_s])
    end
  end

  def advisers
    @advisers.map { |adviser_data| AdviserResult.new(adviser_data) }
  end

  def offices
    @offices
      .map  { |office_data| OfficeResult.new(office_data) }
      .sort { |a, b| a.address_town <=> b.address_town }
  end

  def includes_advice_type?(advice_type)
    public_send(advice_type) > ADVICE_TYPE_NOT_SELECTED_VALUE
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

  alias :free_initial_meeting? :free_initial_meeting
end
