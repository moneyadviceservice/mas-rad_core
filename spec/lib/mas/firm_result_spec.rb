RSpec.describe FirmResult do
  let(:data) do
    {
      '_index'  => 'rad_test',
      '_type'   => 'firms',
      '_id'     => '1',
      '_score'  => nil,
      '_source' => {
        '_id' => 1,
        'registered_name' => 'Financial Advice 1 Ltd.',
        'postcode_searchable' => true,
        'advisers' => [
          {
            '_id'      => 1,
            'name'     => 'Ben Lovell',
            'range'    => 50,
            'location' => { 'lat' => 51.428473, 'lon' => -0.943616 }
          }
        ]
      },
      'sort' => [0.7794549719530739]
    }
  end

  subject { described_class.new(data) }

  describe 'the deserialized result' do
    it 'maps the `id`' do
      expect(subject.id).to eq(1)
    end

    it 'maps the `name`' do
      expect(subject.name).to eq('Financial Advice 1 Ltd.')
    end

    it 'maps the `closest_adviser`' do
      expect(subject.closest_adviser).to eq(0.7794549719530739)
    end

    it 'maps the `total_advisers`' do
      expect(subject.total_advisers).to eq(1)
    end
  end
end
