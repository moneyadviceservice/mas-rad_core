RSpec.describe IndexFirmJob, '#perform' do
  let(:repository) { instance_double(FirmRepository) }
  let(:firm_id) { 3 }
  let(:firm) { Firm.new(id: firm_id) }

  before do
    allow(FirmRepository).to receive(:new).and_return(repository)
  end

  context 'when firm is publishable' do
    before do
      allow(firm).to receive(:publishable?).and_return(true)
    end

    it 'delegates to the firm repository' do
      expect(repository).to receive(:store).with(firm)
      described_class.new.perform(firm)
    end
  end

  context 'when firm is not publishable' do
    before do
      allow(firm).to receive(:publishable?).and_return(false)
    end

    it 'does not delegates to the firm repository' do
      expect(repository).not_to receive(:store).with(firm)
      described_class.new.perform(firm)
    end

    it 'invokes the DeleteFirmJob to remove the firm from the directory' do
      expect(DeleteFirmJob).to receive(:perform_later).with(firm_id)
      described_class.new.perform(firm)
    end
  end
end
