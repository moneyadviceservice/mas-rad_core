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

  def geocode
    return false unless valid?
    return true unless needs_to_be_geocoded?

    self.coordinates = ModelGeocoder.geocode(self)
    add_geocoding_failed_error unless geocoded?

    geocoded?
  end

  def needs_to_be_geocoded?
    !geocoded? || has_address_changes?
  end

  def save_with_geocoding
    geocode && save
  end

  def update_with_geocoding(params)
    self.attributes = params
    save_with_geocoding
  end
end
