class ElasticSearchClient
  attr_reader :index, :server

  def initialize
    @index  = "rad_#{Rails.env}"
    @server = ENV.fetch('BONSAI_URL', 'http://localhost:9200')
  end
end
