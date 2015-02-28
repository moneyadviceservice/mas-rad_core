class SearchResult
  attr_reader :raw_response

  def initialize(response)
    @raw_response = response
  end

  def firms
    return [] unless raw_response.status.ok?

    @firms ||= hits.map { |hit| FirmResult.new(hit) }
  end

  private

  def hits
    json = JSON.parse(raw_response.body.to_s)

    if json['hits'] && json['hits']['hits']
      json['hits']['hits']
    else
      []
    end
  end
end
