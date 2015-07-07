class FirmSerializer < ActiveModel::Serializer
  self.root = false

  attributes :_id,
    :registered_name,
    :postcode_searchable,
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

  def retirement_income_products
    boolean_to_percentage object.retirement_income_products_flag
  end

  def pension_transfer
    boolean_to_percentage object.pension_transfer_flag
  end

  def options_when_paying_for_care
    boolean_to_percentage object.long_term_care_flag
  end

  def equity_release
    boolean_to_percentage object.equity_release_flag
  end

  def inheritance_tax_planning
    boolean_to_percentage object.inheritance_tax_and_estate_planning_flag
  end

  def wills_and_probate
    boolean_to_percentage object.wills_and_probate_flag
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

  private

  def boolean_to_percentage(boolean)
    boolean ? 100 : 0
  end
end
