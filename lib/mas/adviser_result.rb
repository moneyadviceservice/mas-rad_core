class AdviserResult
  attr_reader :id, :name, :postcode, :range, :location, :qualification_ids, :accreditation_ids
  attr_accessor :distance

  def initialize(data)
    @id       = data['_id']
    @name     = data['name']
    @postcode = data['postcode']
    @range    = data['range']
    @location = Location.new data['location']['lat'], data['location']['lon']
    @qualification_ids = data['qualification_ids']
    @accreditation_ids = data['accreditation_ids']
  end
end
