class FirmResult
  attr_reader :id,
    :name,
    :closest_adviser,
    :total_advisers

  def initialize(data)
    source = data['_source']
    @id    = source['_id']
    @name  = source['registered_name']
    @total_advisers  = source['advisers'].count
    @closest_adviser = data['sort'].first
  end
end
