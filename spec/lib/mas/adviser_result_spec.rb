RSpec.describe AdviserResult do
  let(:data) {
    {
      '_id'      => 123,
      'name'     => 'Mandy Advici',
      'range'    => 50,
      'location' => { 'lat' => 51.5180697, 'lon' => -0.1085203 }
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

    it 'maps the range' do
      expect(subject.range).to eq(50)
    end

    it 'maps the location with latitude and longitude' do
      expect(subject.location.latitude).to eq(51.5180697)
      expect(subject.location.longitude).to eq(-0.1085203)
    end
  end
end