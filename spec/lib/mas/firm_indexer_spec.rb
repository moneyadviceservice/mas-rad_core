RSpec.describe FirmIndexer do
  let(:firm_repo_instance) { double }
  before do
    allow(FirmRepository).to receive(:new).and_return(firm_repo_instance)
  end

  def expect_store
    expect(firm_repo_instance).to receive(:store).with(firm)
  end

  def expect_delete
    expect(firm_repo_instance).to receive(:delete).with(firm.id)
  end

  describe '#index_firm' do
    subject { described_class.index_firm(firm) }
    let(:firm) { FactoryGirl.create(:publishable_firm) }

    context 'when the firm is publishable' do
      it 'stores the firm in the index' do
        expect_store
        subject
      end
    end

    context 'when the firm is not publishable' do
      let(:firm) { FactoryGirl.create(:firm_without_offices, :without_advisers) }

      it 'attempts to remove the firm from the index in case it was previously published' do
        expect_delete
        subject
      end
    end

    context 'when the firm has been destroyed' do
      it 'deletes the firm from the index' do
        expect_delete
        firm.destroy
        subject
      end
    end
  end

  describe '#handle_firm_changed' do
    let(:firm) { FactoryGirl.create(:firm) }

    it 'delegates to #index_firm' do
      expect(described_class).to receive(:index_firm).with(firm)
      described_class.handle_firm_changed(firm)
    end
  end
end
