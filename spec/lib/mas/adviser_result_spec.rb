RSpec.describe AdviserResult do
  let(:data) {
    {
      '_id'      => 123,
      'name'     => 'Mandy Advici',
      'postcode' => 'EC1N 2TD',
      'range'    => 50,
      'location' => { 'lat' => 51.5180697, 'lon' => -0.1085203 },
      'qualification_ids' => [1,2,3,4,5],
      'accreditation_ids' => [2,3,4]
    }
  }

  subject { described_class.new(data) }

  describe 'the deserialized adviser result' do
    it 'maps id' do
      expect(subject.id).to eq(123)
    end

    it 'maps the name' do
      expect(subject.name).to eq('Mandy Advici')
    end

    it 'maps the postcode' do
      expect(subject.postcode).to eq('EC1N 2TD')
    end

    it 'maps the range' do
      expect(subject.range).to eq(50)
    end

    it 'maps the location with latitude and longitude' do
      expect(subject.location.latitude).to eq(51.5180697)
      expect(subject.location.longitude).to eq(-0.1085203)
    end

    it 'is able to store distance during geosorting' do
      subject.distance = 15
      expect(subject.distance).to eql(15)
    end

    it 'maps qualification_ids' do
      expect(subject.qualification_ids).to eq([1,2,3,4,5])
    end

    it 'maps accreditation_ids' do
      expect(subject.accreditation_ids).to eq([2,3,4])
    end

  end
end
