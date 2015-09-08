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

    specify 'expected status' do
      expect(subject).to be_persisted
      expect(subject).to be_valid
      expect(subject).not_to be_publishable
      expect(subject).not_to be_trading_name
    end

    specify 'associations' do
      expect(subject.principal).not_to be_present
      expect(subject).to have(:no).offices
      expect(subject).to have(:no).advisers
      expect(subject).to have(:no).trading_names
    end
  end

  describe 'factory :onboarded_firm' do
    let(:factory) { :onboarded_firm }

    specify 'expected status' do
      expect(subject).to be_persisted
      expect(subject).to be_valid
      expect(subject).to be_publishable
      expect(subject).not_to be_trading_name
    end

    specify 'associations' do
      expect(subject.principal).not_to be_present
      expect(subject).to have(1).offices
      expect(subject).to have(1).advisers
      expect(subject).to have(:no).trading_names
    end
  end

  describe 'factory :not_onboarded_firm' do
    let(:factory) { :not_onboarded_firm }

    specify 'expected status' do
      expect(subject).not_to be_persisted
      expect(subject).not_to be_valid
      expect(subject).not_to be_publishable
      expect(subject).not_to be_trading_name
    end

    specify 'associations' do
      expect(subject.principal).not_to be_present
      expect(subject).to have(:no).offices
      expect(subject).to have(:no).advisers
      expect(subject).to have(:no).trading_names
    end
  end

  describe 'factory :firm_with_advisers' do
    let(:factory) { :firm_with_advisers }

    specify 'expected status' do
      expect(subject).to be_persisted
      expect(subject).to be_valid
      expect(subject).not_to be_publishable
      expect(subject).not_to be_trading_name
    end

    specify 'associations' do
      expect(subject.principal).not_to be_present
      expect(subject).to have(:no).offices
      expect(subject).to have(3).advisers
      expect(subject).to have(:no).trading_names
    end
  end

  describe 'factory :firm_with_offices' do
    let(:factory) { :firm_with_offices }

    specify 'expected status' do
      expect(subject).to be_persisted
      expect(subject).to be_valid
      expect(subject).to be_publishable
      expect(subject).not_to be_trading_name
    end

    specify 'associations' do
      expect(subject.principal).not_to be_present
      expect(subject).to have(3).offices
      expect(subject).to have(:no).advisers
      expect(subject).to have(:no).trading_names
    end
  end

  describe 'factory :firm_with_trading_names' do
    let(:factory) { :firm_with_trading_names }

    specify 'expected status' do
      expect(subject).to be_persisted
      expect(subject).to be_valid
      expect(subject).not_to be_publishable
      expect(subject).not_to be_trading_name
    end

    specify 'associations' do
      expect(subject.principal).not_to be_present
      expect(subject).to have(:no).offices
      expect(subject).to have(:no).advisers

      expect(subject).to have(3).trading_names
      expect(subject.trading_names).to all(have_attributes(fca_number: subject.fca_number))
      expect(subject.trading_names).to all(have_attributes(parent: subject))
    end
  end

  describe 'factory :firm_with_principal' do
    let(:factory) { :firm_with_principal }

    specify 'expected status' do
      expect(subject).to be_persisted
      expect(subject).to be_valid
      expect(subject).not_to be_publishable
      expect(subject).not_to be_trading_name
    end

    specify 'associations' do
      expect(subject.principal).to be_present
      expect(subject.principal.fca_number).to eq(subject.fca_number)
      # expect(subject.principal.firm).to eq(subject) # @todo fails. Creates principal with 2 main firms !!!

      expect(subject).to have(:no).offices
      expect(subject).to have(:no).advisers
      expect(subject).to have(:no).trading_names
    end
  end

  describe 'factory :invalid_firm' do
    let(:factory) { :invalid_firm }

    specify 'expected status' do
      expect(subject).not_to be_persisted
      expect(subject).not_to be_valid
      expect(subject).not_to be_publishable
      expect(subject).not_to be_trading_name
    end

    specify 'associations' do
      expect(subject.principal).not_to be_present
      expect(subject).to have(:no).offices
      expect(subject).to have(:no).advisers
      expect(subject).to have(:no).trading_names
    end
  end
end
