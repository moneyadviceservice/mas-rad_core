module Geocode
  def latitude=(value)
    value = value.to_f.round(6) unless value.nil?
    write_attribute(:latitude, value)
  end

  def longitude=(value)
    value = value.to_f.round(6) unless value.nil?
    write_attribute(:longitude, value)
  end

  def geocode!(coordinates)
    self.latitude, self.longitude = coordinates
    save!(callbacks: false)
  end
end
