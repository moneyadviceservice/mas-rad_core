module GeocodableSync
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
