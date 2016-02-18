class Postcode
  def filter_postcodes_by_country(postcodes, country)
    map_postcodes_to_country(postcodes)
      .select { |postcode, postcode_country| postcode_country == country }
      .map { |postcode, postcode_country| postcode }
  end

  private

  # Make sure we only request 100 at a time
  def map_postcodes_to_country(postcodes)
    postcodes
      .uniq
      .each_slice(100)
      .map { |slice| map_postcodes_slice_to_country(slice) }
      .reduce(&:merge)
  end

  def map_postcodes_slice_to_country(postcodes)
    request = Net::HTTP::Post.new('/postcodes')
    request.set_form_data(postcodes: postcodes)

    response = Net::HTTP.new('api.postcodes.io').request(request)

    if response.code.to_i == 200
      result = JSON.parse(response.read_body)['result'].map { |r| r['result'] }.compact
      result.each_with_object({}) do |r, obj|
        obj[r['postcode']] = r['country']
      end
    else
      {}
    end
  end
end
