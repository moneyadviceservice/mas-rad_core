class ElasticSearchClient
  attr_reader :index, :server

  def initialize
    @index  = "rad_#{Rails.env}"
    @server = ENV.fetch('BONSAI_URL', 'http://localhost:9200')
  end

  def store(path, json)
    res = HTTP.put(uri_for(path), json: json)
    res.status.ok?
  end

  def search(path, json = {})
    res = HTTP.post(uri_for(path), json: json)
    SearchResult.new(res)
  end

  private

  def uri_for(path)
    "#{server}/#{index}/#{path}"
  end
end
