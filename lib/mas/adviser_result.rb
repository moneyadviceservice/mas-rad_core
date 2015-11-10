class AdviserResult
  attr_reader :id, :name, :range, :location

  def initialize(data)
    @id       = data['_id']
    @name     = data['name']
    @range    = data['range']
    @location = Location.new data['location']['lat'], data['location']['lon']
  end
end
