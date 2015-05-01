RSpec.describe DeleteFirmJob, '#perform' do
  let(:repository) { instance_double(FirmRepository) }

  before do
    allow(FirmRepository).to receive(:new).and_return(repository)
  end

  it 'delegates to the firm repository' do
    expect(repository).to receive(:delete).with(1)

    described_class.new.perform(1)
  end
end
