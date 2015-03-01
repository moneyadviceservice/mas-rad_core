class ElasticSearchClient
  attr_reader :index, :server

  def initialize
    @index  = "rad_#{Rails.env}"
    @server = ENV.fetch('BONSAI_URL', 'http://localhost:9200')
  end

  def store(path, json)
    res = http.put(uri_for(path), json: json)
    res.status.ok?
  end

  def search(path, json = '')
    http.post(uri_for(path), body: json)
  end

  private

  def http
    authenticate? ? HTTP.basic_auth(user: username, pass: password) : HTTP
  end

  def authenticate?
    username && password
  end

  def username
    ENV['BONSAI_USERNAME']
  end

  def password
    ENV['BONSAI_PASSWORD']
  end

  def uri_for(path)
    "#{server}/#{index}/#{path}"
  end
end
