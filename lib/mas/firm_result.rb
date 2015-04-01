class FirmResult
  DIRECTLY_MAPPED_FIELDS = [
    :address_line_one,
    :address_line_two,
    :address_town,
    :address_county,
    :address_postcode,
    :telephone_number,
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
    :closest_adviser,
    :total_advisers,
    *DIRECTLY_MAPPED_FIELDS,
    *TYPES_OF_ADVICE_FIELDS

  def initialize(data)
    source = data['_source']
    @id    = source['_id']
    @name  = source['registered_name']
    @total_advisers  = source['advisers'].count
    @closest_adviser = data['sort'].last

    (DIRECTLY_MAPPED_FIELDS + TYPES_OF_ADVICE_FIELDS).each do |field|
      instance_variable_set("@#{field}", source[field.to_s])
    end
  end

  def types_of_advice
    TYPES_OF_ADVICE_FIELDS.select { |field| public_send(field).nonzero? }
  end

  def minimum_fixed_fee?
    minimum_fixed_fee.present?
  end

  def minimum_pot_size_id
    investment_sizes.first
  end

  alias :free_initial_meeting? :free_initial_meeting
end
