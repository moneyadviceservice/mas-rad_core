class FirmSerializer < ActiveModel::Serializer
  self.root = false

  attributes :_id,
    :registered_name,
    :postcode_searchable,
    :address_line_one,
    :address_town,
    :address_county,
    :address_postcode,
    :telephone_number,
    :website_address,
    :email_address,
    :free_initial_meeting,
    :minimum_fixed_fee,
    :retirement_income_products,
    :pension_transfer,
    :options_when_paying_for_care,
    :equity_release,
    :inheritance_tax_planning,
    :wills_and_probate,
    :other_advice_methods,
    :investment_sizes,
    :in_person_advice_methods,
    :adviser_qualification_ids,
    :adviser_accreditation_ids

  has_many :advisers

  def adviser_accreditation_ids
    object.accreditation_ids
  end

  def adviser_qualification_ids
    object.qualification_ids
  end

  def advisers
    object.advisers.geocoded
  end

  def postcode_searchable
    object.postcode_searchable?
  end

  def website_address
    object.principal.try(:website_address)
  end

  def retirement_income_products
    object.retirement_income_products_percent
  end

  def pension_transfer
    object.pension_transfer_percent
  end

  def options_when_paying_for_care
    object.long_term_care_percent
  end

  def equity_release
    object.equity_release_percent
  end

  def inheritance_tax_planning
    object.inheritance_tax_and_estate_planning_percent
  end

  def wills_and_probate
    object.wills_and_probate_percent
  end

  def _id
    object.id
  end

  def other_advice_methods
    object.other_advice_method_ids
  end

  def in_person_advice_methods
    object.in_person_advice_method_ids
  end

  def investment_sizes
    object.investment_size_ids
  end
end
