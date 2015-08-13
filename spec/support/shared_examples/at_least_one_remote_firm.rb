##
# Needs:
#   principal    = instance of Principal with two firms attached (parent_firm and trading_name)
#   parent_firm  = an instance of Firm with the same FCA Number as the Principal but no parent firm
#   trading_name = an instance of Firm with the same FCA Number as the Principal and the parent_firm as the parent firm
RSpec.shared_examples 'at least one remote firm' do
  context 'and neither firm has advisers' do
    before :each do
      expect(parent_firm.advisers.any?).to eql(false)
      expect(trading_name.advisers.any?).to eql(false)
    end

    it 'returns :onboarded' do
      expect(principal.next_onboarding_action).to eql(:onboarded)
    end
  end

  context 'and the parent firm has advisers' do
    before :each do
      create(:adviser, firm: parent_firm)
      expect(trading_name.advisers.any?).to eql(false)
      principal.reload
    end

    it 'returns :onboarded' do
      expect(principal.next_onboarding_action).to eql(:onboarded)
    end
  end

  context 'and the trading name has advisers' do
    before :each do
      expect(parent_firm.advisers.any?).to eql(false)
      create(:adviser, firm: trading_name)
      principal.reload
    end

    it 'returns :onboarded' do
      expect(principal.next_onboarding_action).to eql(:onboarded)
    end
  end

  context 'and both firms have advisers' do
    before :each do
      create(:adviser, firm: parent_firm)
      create(:adviser, firm: trading_name)
      principal.reload
    end

    it 'returns :onboarded' do
      expect(principal.next_onboarding_action).to eql(:onboarded)
    end
  end
end
