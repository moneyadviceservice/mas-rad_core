module Geocodable
  def self.included(model)
    model.scope :geocoded, -> { model.where.not(latitude: nil, longitude: nil) }
  end

  def latitude=(value)
    value = value.to_f.round(6) unless value.nil?
    write_attribute(:latitude, value)
  end

  def longitude=(value)
    value = value.to_f.round(6) unless value.nil?
    write_attribute(:longitude, value)
  end

  def geocoded?
    coordinates.compact.present?
  end

  def coordinates
    [latitude, longitude]
  end

  def coordinates=(coordinates)
    self.latitude, self.longitude = coordinates
  end

  def update_coordinates!(coordinates)
    self.coordinates = coordinates
    update_columns(latitude: latitude, longitude: longitude)
  end
end
