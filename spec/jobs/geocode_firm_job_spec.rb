require 'geocoder'

RSpec.describe GeocodeFirmJob do
  let(:job) { GeocodeFirmJob.new }

  subject(:firm) { create(:firm) }

  before do
    firm.main_office.update!(address_postcode: address_postcode)
    firm.reload
  end

  describe '#perform' do
    context 'when the firm address can be geocoded' do
      let(:address_postcode) { 'EC1N 2TD' }

      subject do
        VCR.use_cassette('geocode-one-result') do
          job.perform(firm)
        end
      end

      it 'the firm is geocoded with the coordinates' do
        subject

        expect(firm.coordinates).to contain_exactly(51.51807, -0.10852)
      end

      it 'the firm is scheduled for indexing' do
        expect { subject }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(1)
      end
    end

    context 'when firm address cannot be geocoded' do
      let(:address_postcode) { 'XX1 1XX' }

      subject do
        VCR.use_cassette('geocode-no-results') do
          job.perform(firm)
        end
      end

      it 'the firm coordinates are nil' do
        subject

        expect(firm.coordinates).to contain_exactly(nil, nil)
      end

      it 'the firm is not scheduled for indexing' do
        expect { subject }.not_to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }
      end
    end
  end
end
