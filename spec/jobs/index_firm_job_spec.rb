RSpec.describe IndexFirmJob, '#perform' do
  let(:firm) { Firm.new }

  it 'delegates to the firm indexer' do
    expect(FirmIndexer).to receive(:index_firm).with(firm)
    described_class.new.perform(firm)
  end
end
