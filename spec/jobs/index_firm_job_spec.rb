RSpec.describe IndexFirmJob, '#perform' do
  let(:firm) { Firm.new }
  let(:repository) { instance_double(FirmRepository) }

  before do
    allow(FirmRepository).to receive(:new).and_return(repository)
  end

  it 'delegates to the firm repository' do
    expect(repository).to receive(:store).with(firm)

    described_class.new.perform(firm)
  end
end
