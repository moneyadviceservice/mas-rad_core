RSpec.describe 'Firm factory' do
  subject do
    begin
      FactoryGirl.create(factory)
    rescue ActiveRecord::RecordInvalid
      FactoryGirl.build(factory)
    end
  end

  describe 'factory :firm (default factory)' do
    let(:factory) { :firm }

    context 'expected status' do
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }
      it { is_expected.not_to be_publishable }
      it { is_expected.not_to be_trading_name }
    end

    context 'associations' do
      it { is_expected.to have(:no).offices }
      it { is_expected.to have(:no).advisers }
    end
  end

  describe 'factory :onboarded_firm' do
    let(:factory) { :onboarded_firm }

    context 'expected status' do
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }
      it { is_expected.to be_publishable }
      it { is_expected.not_to be_trading_name }
    end

    context 'associations' do
      it { is_expected.to have(1).offices }
      it { is_expected.to have(1).advisers }
    end
  end

  describe 'factory :not_onboarded_firm' do
    let(:factory) { :not_onboarded_firm }

    context 'expected status' do
      it { is_expected.not_to be_persisted }
      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_publishable }
      it { is_expected.not_to be_trading_name }
    end

    context 'associations' do
      it { is_expected.to have(:no).offices }
      it { is_expected.to have(:no).advisers }
    end
  end

  describe 'factory :invalid_firm' do
    let(:factory) { :invalid_firm }

    context 'expected status' do
      it { is_expected.not_to be_persisted }
      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_publishable }
      it { is_expected.not_to be_trading_name }
    end

    context 'associations' do
      it { is_expected.to have(:no).offices }
      it { is_expected.to have(:no).advisers }
    end
  end
end
