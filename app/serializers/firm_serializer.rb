class FirmSerializer < ActiveModel::Serializer
  self.root = false

  attributes :_id, :registered_name, :postcode_searchable

  has_many :advisers

  def postcode_searchable
    object.postcode_searchable?
  end

  def _id
    object.id
  end
end
