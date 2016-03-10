class AdviserResult
  attr_reader :id, :name, :postcode, :range, :location
  attr_accessor :distance

  def initialize(data)
    @id       = data['_id']
    @name     = data['name']
    @postcode = data['postcode']
    @range    = data['range']
    @location = Location.new data['location']['lat'], data['location']['lon']
  end
end
