RSpec.describe OfficeResult do
  let(:data) do
    {
      '_id'              => 123,
      'address_line_one' => 'c/o Postman Pat',
      'address_line_two' => 'Forge Cottage',
      'address_town'     => 'Greendale',
      'address_county'   => 'Cumbria',
      'address_postcode' => 'LA8 9BE',
      'email_address'    => 'postie@example.com',
      'telephone_number' => '020 8595 2346',
      'disabled_access'  => true,
      'website'          => 'http://www.postman.com',
      'location' => { 'lat' => 51.5180697, 'lon' => -0.1085203 }
    }
  end

  subject { described_class.new(data) }

  describe '#new' do
    specify { expect(subject.id).to eq(123) }
    specify { expect(subject.address_line_one).to eq('c/o Postman Pat') }
    specify { expect(subject.address_line_two).to eq('Forge Cottage') }
    specify { expect(subject.address_town).to eq('Greendale') }
    specify { expect(subject.address_county).to eq('Cumbria') }
    specify { expect(subject.address_postcode).to eq('LA8 9BE') }
    specify { expect(subject.email_address).to eq('postie@example.com') }
    specify { expect(subject.telephone_number).to eq('020 8595 2346') }
    specify { expect(subject.disabled_access).to eq(true) }
    specify { expect(subject.website).to eq('http://www.postman.com') }

    it 'maps the location with latitude and longitude' do
      expect(subject.location.latitude).to eq(51.5180697)
      expect(subject.location.longitude).to eq(-0.1085203)
    end
  end

  it 'is able to store distance during geosorting' do
    subject.distance = 15
    expect(subject.distance).to eql(15)
  end
end
