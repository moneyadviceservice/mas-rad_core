class FirmRepository
  attr_reader :client, :serializer

  def initialize(client = ElasticSearchClient, serializer = FirmSerializer)
    @client     = client.new
    @serializer = serializer
  end

  def store(firm)
    json = serializer.new(firm).as_json
    path = "#{firm.model_name.plural}/#{firm.to_param}"

    client.store(path, json)
  end

  def search(query)
    client.search('firms/_search', query.as_json)
  end
end
