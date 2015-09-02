RSpec.describe IndexFirmJob, '#perform' do
  let(:repository) { instance_double(FirmRepository) }
  let(:firm) { Firm.new }

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
  end
end
