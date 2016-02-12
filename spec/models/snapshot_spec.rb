RSpec.describe Snapshot do
  describe '#query_firms_with_no_minimum_fee' do
    before do
      FactoryGirl.create(:firm, minimum_fixed_fee: 0)
      FactoryGirl.create(:firm, minimum_fixed_fee: 0)
      FactoryGirl.create(:firm, minimum_fixed_fee: 500)
    end

    it { expect(subject.query_firms_with_no_minimum_fee.count).to eq(2) }
  end

  describe 'creating a snapshot' do
    before do
      FactoryGirl.create(:firm, minimum_fixed_fee: 0)
      FactoryGirl.create(:firm, minimum_fixed_fee: 0)
      FactoryGirl.create(:firm, minimum_fixed_fee: 500)
    end

    it 'runs the queries and stores the count on the appropritate attribute' do
      snapshot = Snapshot.create
      expect(snapshot.firms_with_no_minimum_fee).to eq(2)
    end
  end
end
