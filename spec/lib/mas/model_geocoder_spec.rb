RSpec.describe ModelGeocoder do
  let(:model_class) do
    Class.new do
      attr_accessor :address_line_one, :address_line_two, :address_postcode

      def full_street_address
        [address_line_one, address_line_two, address_postcode, 'United Kingdom'].reject(&:blank?).join(', ')
      end
    end
  end

  let(:model) do
    model_class.new.tap do |thing|
      thing.address_line_one = address_line_one
      thing.address_line_two = address_line_two
      thing.address_postcode = address_postcode
    end
  end

  let(:address_line_one) { '120 Holborn' }
  let(:address_line_two) { 'London' }
  let(:address_postcode) { 'EC1N 2TD' }
  let(:expected_coordinates) { [51.5180697, -0.1085203] }

  describe '#geocode' do
    context 'when the model address can be geocoded' do
      it 'returns the coordinates' do
        VCR.use_cassette('geocode-one-result') do
          expect(ModelGeocoder.geocode(model)).to eql(expected_coordinates)
        end
      end
    end

    context 'when model address cannot be geocoded' do
      let(:address_line_one) { '1000 Fantasy Ave' }
      let(:address_line_two) { 'Neverland' }
      let(:address_postcode) { 'ABC 123' }

      it 'returns nil' do
        VCR.use_cassette('geocode-no-results') do
          expect(ModelGeocoder.geocode(model)).to be(nil)
        end
      end
    end
  end
end
