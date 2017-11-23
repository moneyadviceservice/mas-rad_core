class AdviserSerializer < ActiveModel::Serializer

  attributes :_id, :name, :postcode, :range, :location, :range_location, :qualification_ids, :accreditation_ids

  def _id
    object.id
  end

  def range
    object.travel_distance
  end

  def location
    {
      lat: object.latitude,
      lon: object.longitude
    }
  end

  def range_location
    {
      type: :circle,
      coordinates: [object.longitude, object.latitude],
      radius: "#{object.travel_distance}miles"
    }
  end
end
