class ElasticSearchClient
  attr_reader :index, :server

  def initialize
    @index  = "rad_#{Rails.env}"
    @server = ENV.fetch('BONSAI_URL', 'http://localhost:9200')
  end

  def store(path, json)
    uri = "#{server}/#{index}/#{path}"
    res = HTTP.put(uri, json: json)

    res.status.ok?
  end
end
