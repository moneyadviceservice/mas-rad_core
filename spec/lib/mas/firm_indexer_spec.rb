RSpec.describe FirmIndexer do
  let(:firm_repo_instance) { double }
  before do
    allow(FirmRepository).to receive(:new).and_return(firm_repo_instance)
  end

  describe '#index_firm' do
    subject { described_class.index_firm(firm) }

    context 'when the firm is publishable' do
      let(:firm) { FactoryGirl.create(:publishable_firm) }

      it 'stores the firm in the index' do
        expect(firm_repo_instance).to receive(:store).with(firm)
        subject
      end
    end

    context 'when the firm is not publishable' do
      let(:firm) { FactoryGirl.create(:firm_without_offices, :without_advisers) }

      it 'attempts to remove the firm from the index in case it was previously published' do
        expect(firm_repo_instance).to receive(:delete).with(firm.id)
        subject
      end
    end
  end
end
