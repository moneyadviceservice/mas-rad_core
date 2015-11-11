class OfficeSerializer < ActiveModel::Serializer
  self.root = false

  attributes :_id, :address_line_one, :address_line_two, :address_town,
             :address_county, :address_postcode, :email_address,
             :telephone_number, :disabled_access, :location

  def _id
    object.id
  end

  def location
    {
      lat: object.latitude,
      lon: object.longitude
    }
  end
end
