RSpec.describe ModelGeocoder do
  let(:model_class) do
    Class.new do
      attr_accessor :address_postcode, :longitude, :latitude

      def update_coordinates!(*args); end

      def full_street_address
        "#{address_postcode}, United Kingdom"
      end
    end
  end

  let(:model) do
    model_class.new.tap do |thing|
      thing.address_postcode = address_postcode
    end
  end

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
      let(:address_postcode) { 'XX1 1XX' }

      it 'returns nil' do
        VCR.use_cassette('geocode-no-results') do
          expect(ModelGeocoder.geocode(model)).to be(nil)
        end
      end
    end
  end

  describe '#geocode!' do
    context 'when the model address can be geocoded' do
      before do
        allow(ModelGeocoder).to receive(:geocode).and_return(expected_coordinates)
      end

      it 'calls model.update_coordinates! with the coordinates' do
        expect(model).to receive(:update_coordinates!).with(expected_coordinates)
        ModelGeocoder.geocode!(model)
      end

      it 'returns the true' do
        expect(ModelGeocoder.geocode!(model)).to be(true)
      end
    end

    context 'when model address cannot be geocoded' do
      before do
        allow(ModelGeocoder).to receive(:geocode).and_return(nil)
      end

      # This side effect is required while the geocoding is done on a background job
      it 'calls model.update_coordinates! with nil' do
        expect(model).to receive(:update_coordinates!).with(nil)
        ModelGeocoder.geocode!(model)
      end

      it 'returns false' do
        expect(ModelGeocoder.geocode!(model)).to be(false)
      end
    end
  end
end
