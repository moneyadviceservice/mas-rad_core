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
        'address_line_one' => '64 Somewhere',
        'address_town' => 'Romford',
        'address_county' => 'Essex',
        'address_postcode' => 'RM1 1AL',
        'telephone_number' => '0208 595 2346',
        'website_address' => 'http://www.example.com',
        'email_address' => 'someone@example.com',
        'free_initial_meeting' => true,
        'minimum_fixed_fee' => 999,
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

    it 'maps the `address_line_one`' do
      expect(subject.address_line_one).to eq('64 Somewhere')
    end

    it 'maps the `address_town`' do
      expect(subject.address_town).to eq('Romford')
    end

    it 'maps the `address_county`' do
      expect(subject.address_county).to eq('Essex')
    end

    it 'maps the `address_postcode`' do
      expect(subject.address_postcode).to eq('RM1 1AL')
    end

    it 'maps the `telephone_number`' do
      expect(subject.telephone_number).to eq('0208 595 2346')
    end

    it 'maps the `website_address`' do
      expect(subject.website_address).to eq('http://www.example.com')
    end

    it 'maps the `email_address`' do
      expect(subject.email_address).to eq('someone@example.com')
    end

    it 'maps the `free_initial_meeting`' do
      expect(subject.free_initial_meeting).to eq(true)
    end

    it 'maps the `minimum_fixed_fee`' do
      expect(subject.minimum_fixed_fee).to eq(999)
    end

    it 'maps the `total_advisers`' do
      expect(subject.total_advisers).to eq(1)
    end

    it 'maps the `closest_adviser`' do
      expect(subject.closest_adviser).to eq(0.7794549719530739)
    end

    context 'when sorted by types of advice first' do
      before { data['sort'].unshift(123) }

      it 'maps the `closest_adviser`' do
        expect(subject.closest_adviser).to eq(0.7794549719530739)
      end
    end
  end
end
