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

  def expect_no_action
    expect(firm_repo_instance).to receive(:store).with(firm).exactly(0).times
    expect(firm_repo_instance).to receive(:delete).with(firm.id).exactly(0).times
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
    let(:handle_firm_changed) { described_class.method(:handle_firm_changed) }
    let(:index_firm) { described_class.method(:index_firm) }

    it 'delegates to #index_firm' do
      expect(handle_firm_changed).to eq(index_firm)
    end
  end

  describe '#handle_aggregate_changed' do
    let(:firm) { FactoryGirl.create(:firm_with_offices) }
    let!(:aggregate) { firm.offices.first }
    subject { described_class.handle_aggregate_changed(aggregate) }

    context 'when the aggregate record has changed' do
      it 'stores the firm in the index' do
        aggregate.update!(address_line_one: 'A change of address')
        expect_store
        subject
      end
    end

    context 'when the aggregate record has been destroyed' do
      it 'stores the firm in the index' do
        aggregate.destroy
        expect_store
        subject
      end
    end

    context 'when the aggregate record\'s firm has been destroyed' do
      it 'does nothing' do
        firm.destroy
        expect_no_action
        subject
      end
    end
  end

  describe '#associated_firm_destroyed?' do
    let(:firm) { FactoryGirl.create(:firm_with_offices) }
    let(:aggregate) { firm.offices.first }
    subject { described_class.associated_firm_destroyed?(aggregate) }

    context 'when the firm instance and db record exist' do
      it { is_expected.to be(false) }
    end

    context 'when firm has been destroyed before the association has been loaded' do
      before do
        aggregate # load the aggregate, but not the aggregate.firm association
        firm.destroy
        expect(aggregate.firm).to be_nil
      end

      it { is_expected.to be(true) }
    end

    context 'when the aggregate.firm instance has been destroyed' do
      before { aggregate.firm.destroy }
      it { is_expected.to be(true) }
    end

    context 'when another instance of this firm has been destroyed' do
      let(:other_instance) { Firm.find(firm.id) }

      before do
        aggregate.firm # Load the aggregate.firm instance into memory
        other_instance.destroy
      end

      it { is_expected.to be(true) }
    end
  end
end
