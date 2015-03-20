class FirmResult
  DIRECTLY_MAPPED_FIELDS = [
    :address_line_one,
    :address_town,
    :address_county,
    :address_postcode,
    :telephone_number,
    :website_address,
    :email_address,
    :free_initial_meeting,
    :minimum_fixed_fee,
    :other_advice_methods,
    :in_person_advice_methods
  ]

  attr_reader :id,
    :name,
    :closest_adviser,
    :total_advisers,
    *DIRECTLY_MAPPED_FIELDS

  def initialize(data)
    source = data['_source']
    @id    = source['_id']
    @name  = source['registered_name']
    @total_advisers  = source['advisers'].count
    @closest_adviser = data['sort'].last

    DIRECTLY_MAPPED_FIELDS.each do |field|
      instance_variable_set("@#{field}", source[field.to_s])
    end
  end
end
