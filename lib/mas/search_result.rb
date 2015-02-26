class SearchResult
  attr_reader :raw_response

  def initialize(response)
    @raw_response = response
  end

  def firms
    return [] unless raw_response.status.ok?
  end
end
