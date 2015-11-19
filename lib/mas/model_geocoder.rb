module ModelGeocoder
  def self.geocode(geocodable)
    Geocoder.coordinates(geocodable.full_street_address)
  end
end
