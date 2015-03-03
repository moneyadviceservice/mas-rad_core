class FirmSerializer < ActiveModel::Serializer
  self.root = false

  attributes :_id,
    :registered_name,
    :postcode_searchable,
    :options_when_paying_for_care,
    :equity_release,
    :inheritance_tax_planning,
    :wills_and_probate,
    :other_advice_methods

  has_many :advisers

  def postcode_searchable
    object.postcode_searchable?
  end

  def options_when_paying_for_care
    object.long_term_care_percent.to_i > 0
  end

  def equity_release
    object.equity_release_percent.to_i > 0
  end

  def inheritance_tax_planning
    object.inheritance_tax_and_estate_planning_percent.to_i > 0
  end

  def wills_and_probate
    object.wills_and_probate_percent.to_i > 0
  end

  def _id
    object.id
  end

  def other_advice_methods
    object.other_advice_method_ids
  end
end
