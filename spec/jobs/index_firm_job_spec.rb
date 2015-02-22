RSpec.describe IndexFirmJob, '#perform' do
  subject { described_class.new }

  it 'indexes the firm' do
    skip
    adviser = create(:adviser)
    subject.perform(adviser.firm)
  end
end
