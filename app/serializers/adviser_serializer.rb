class AdviserSerializer < ActiveModel::Serializer
  self.root = false

  attributes :_id, :name, :range, :location

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
end
