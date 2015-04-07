class SearchResult
  include Paginateable

  attr_reader :raw_response, :current_page

  def initialize(response, page: 1)
    @raw_response = response
    @current_page = page
  end

  def firms
    return [] unless raw_response.ok?

    @firms ||= hits.map { |hit| FirmResult.new(hit) }
  end

  private

  def json
    @json ||= JSON.parse(raw_response.body)
  end

  def hits
    json['hits']['hits']
  end
end
