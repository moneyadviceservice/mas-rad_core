RSpec.describe GeocodeAdviserJob do
  let(:job) { GeocodeAdviserJob.new }

  let!(:adviser) { create(:adviser, postcode: postcode) }

  describe '#perform' do
    context 'when the adviser postcode can be geocoded' do
      let(:postcode) { 'EC1N 2TD' }

      subject do
        VCR.use_cassette('postcode-one-result') do
          job.perform(adviser)
        end
      end

      it 'the adviser is geocoded with the coordinates' do
        subject

        expect(adviser.coordinates).to contain_exactly(51.51807, -0.10852)
      end

      it 'the adviser firm is scheduled for indexing' do
        expect { subject }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by(1)
      end
    end

    context 'when the adviser postcode cannot be geocoded' do
      let(:postcode) { 'ABC 123' }

      subject do
        VCR.use_cassette('postcode-no-results') do
          job.perform(adviser)
        end
      end

      it 'the adviser coordinates are set to nil' do
        subject

        expect(adviser.coordinates).to contain_exactly(nil, nil)
      end

      it 'the adviser is not scheduled for indexing' do
        expect { subject }.not_to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }
      end
    end
  end
end
