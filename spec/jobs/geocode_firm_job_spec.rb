require 'geocoder'

RSpec.describe GeocodeFirmJob do
  let(:job) { GeocodeFirmJob.new }

  subject(:firm) do
    create(:firm,
      address_line_one: address_line_one,
      address_line_two: address_line_two,
      address_postcode: address_postcode
    )
  end

  describe '#perform' do
    context 'when the geocode is successful' do
      let(:address_line_one) { '120 Holborn' }
      let(:address_line_two) { 'London' }
      let(:address_postcode) { 'EC1N 2TD' }

      before do
        VCR.use_cassette('geocode-one-result') do
          job.perform(firm)
        end
      end

      it 'the firm is populated with the latitude' do
        expect(firm.latitude).to eql(51.5180697)
      end

      it 'the firm is populated with the longitude' do
        expect(firm.longitude).to eql(-0.1085203)
      end
    end
  end
end
