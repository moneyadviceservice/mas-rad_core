RSpec.describe 'Firm factory' do
  def create_invalid(factory)
    FactoryGirl.build(factory).tap { |f| f.save(validation: false) }
  end

  subject { FactoryGirl.create(factory) }

  describe 'factory :firm (default factory)' do
    let(:factory) { :firm }

    context 'expected status' do
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
    subject { create_invalid(factory) }

    context 'expected status' do
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
    subject { create_invalid(factory) }

    context 'expected status' do
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
