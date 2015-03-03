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

  def search(query, page: 1)
    response = client.search("firms/_search?from=#{from_for(page)}", query)
    SearchResult.new(response, page: page)
  end

  def from_for(page)
    return 0 if page == 1

    ((page - 1) * MAS::RadCore::PAGE_SIZE)
  end
end
