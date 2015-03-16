class FirmSerializer < ActiveModel::Serializer
  self.root = false

  attributes :_id,
    :registered_name,
    :postcode_searchable,
    :retirement_income_products,
    :pension_transfer,
    :options_when_paying_for_care,
    :equity_release,
    :inheritance_tax_planning,
    :wills_and_probate,
    :other_advice_methods,
    :investment_sizes

  has_many :advisers

  def advisers
    object.advisers.geocoded
  end

  def postcode_searchable
    object.postcode_searchable?
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

  def investment_sizes
    object.investment_size_ids
  end
end
