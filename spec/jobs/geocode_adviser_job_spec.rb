require 'geocoder'

RSpec.describe GeocodeAdviserJob do
  let(:job) { GeocodeAdviserJob.new }

  subject(:adviser) { create(:adviser, postcode: postcode) }

  describe '#perform' do
    context 'when the adviser postcode can be geocoded' do
      let(:postcode) { 'EC1N 2TD' }

      it 'the adviser is geocoded with the coordinates' do
        VCR.use_cassette('postcode-one-result') do
          expect(adviser).to receive(:geocode!).with([51.5180697, -0.1085203])
          job.perform(adviser)
        end
      end
    end

    context 'when adviser postcode cannot be geocoded' do
      let(:postcode) { 'ABC 123' }

      it 'the latitude and longitude are set to nil' do
        VCR.use_cassette('postcode-no-results') do
          expect(adviser).to receive(:geocode!).with(nil)
          job.perform(adviser)
        end
      end
    end
  end
end
