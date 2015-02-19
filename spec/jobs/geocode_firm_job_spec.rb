RSpec.describe GeocodeFirmJob do
  let(:job) { GeocodeFirmJob.new }

  subject(:firm) { create :firm }

  describe '#perform' do
    context 'when the geocode is successful' do
      let(:latitude) { Faker::Address.latitude.to_f.round(13) }
      let(:longitude) { Faker::Address.latitude.to_f.round(13) }
      let(:result) { double(latitude: latitude, longitude: longitude) }

      before { allow(Geocoder).to receive(:search) { [result] } }

      it 'logs a success to statsd' do
        firm
        expect(Stats).to receive(:increment).with('radsignup.geocode.firm.success')
        job.perform(firm)
      end
    end

    context 'when the geocode is unsuccessful' do
      before { allow(Geocoder).to receive(:search) { [] } }

      it 'logs a failure to statsd' do
        firm
        expect(Stats).to receive(:increment).with('radsignup.geocode.firm.failed')
        job.perform(firm)
      end
    end
  end
end
