RSpec.describe InvestmentSize do
  it_behaves_like 'reference data'
  it_behaves_like 'translatable'
  it_behaves_like 'friendly named'

  context 'identifying the lowest defined value' do
    let(:lower_limit_ordinal) { 1 }
    let(:upper_limit_ordinal) { 5 }
    let(:ordinals) { (lower_limit_ordinal..upper_limit_ordinal).to_a }
    before do
      # Reversing the ordinals so the default sort order is not the same as the
      # order of creation and so hopefully prove we are not dependent on DB
      # allocated IDs in any way
      ordinals.reverse.each do |ordinal|
        FactoryBot.create(:investment_size, order: ordinal)
      end
    end

    describe '.lowest' do
      it 'returns the investment size with the lowest order value' do
        expect(described_class.lowest.order).to eq(lower_limit_ordinal)
      end
    end

    describe '#lowest?' do
      let(:record) { described_class.find_by(order: ordinal) }
      subject { record.lowest? }

      context 'when the subject is the lowest value' do
        let(:ordinal) { lower_limit_ordinal }
        it { is_expected.to be(true) }
      end

      context 'when the subject is not the lowest value' do
        let(:ordinal) { upper_limit_ordinal }
        it { is_expected.to be(false) }
      end
    end
  end
end
