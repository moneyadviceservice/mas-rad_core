RSpec.describe Firm do
  subject(:firm) { build(:firm) }

  describe 'languages_used' do
    context 'when there are no firms' do
      it 'has no languages' do
        expect(Firm.languages_used).to be_empty
      end
    end

    context 'when there are firms with no languages set' do
      it 'has no languages' do
        create(:firm, languages: [])
        expect(Firm.languages_used).to be_empty
      end
    end

    context 'when there are a multiple languages on multiple firms' do
      it 'has has multiple languages' do
        create(:firm, languages: ['sco', 'swe'])
        create(:firm, languages: ['nor', 'lat'])
        expect(Firm.languages_used).to eq(['lat', 'nor', 'sco', 'swe'])
      end

      it 'has has duplicate languages' do
        create(:firm, languages: ['sco', 'swe'])
        create(:firm, languages: ['nor', 'swe'])
        expect(Firm.languages_used).to eq(['nor', 'sco', 'swe'])
      end
    end
  end

  describe 'default behaviour' do
    it 'sets ethical_investing_flag to false' do
      expect(Firm.new.ethical_investing_flag).to be_falsey
    end

    it 'sets sharia_investing_flag to false' do
      expect(Firm.new.sharia_investing_flag).to be_falsey
    end

    it 'sets workplace_financial_advice_flag to false' do
      expect(Firm.new.workplace_financial_advice_flag).to be_falsey
    end

    it 'sets non_uk_residents_flag to false' do
      expect(Firm.new.non_uk_residents_flag).to be_falsey
    end

    it 'sets languages to an array with empty set' do
      expect(Firm.new.languages).to eq []
    end
  end

  describe '#registered?' do
    def set_marker_field(firm, value)
      firm.send("#{Firm::REGISTERED_MARKER_FIELD}=", value)
    end

    it 'is false if the REGISTERED_MARKER_FIELD field is nil' do
      set_marker_field(firm, nil)
      expect(firm).not_to be_registered
    end

    it 'is true if the REGISTERED_MARKER_FIELD field has a valid value' do
      Firm::REGISTERED_MARKER_FIELD_VALID_VALUES.each do |value|
        set_marker_field(firm, value)
        expect(firm).to be_registered
      end
    end
  end

  describe '#postcode_searchable?' do
    it 'delegates to #in_person_advice?' do
      expect(firm).to be_postcode_searchable
    end
  end

  describe '#in_person_advice?' do
    context 'when the firm offers in person advice' do
      it 'is true' do
        expect(firm).to be_in_person_advice
      end
    end

    context 'when the firm does not offer in person advice' do
      it 'is false' do
        firm.in_person_advice_methods.clear

        expect(firm).to_not be_in_person_advice
      end
    end
  end

  describe 'subsidaries' do
    context 'when the firm has a parent' do
      it 'is classed as a subsidiary' do
        expect(build(:subsidiary)).to be_subsidiary
      end
    end

    describe '#subsidiaries' do
      it 'exposes subsidiaries' do
        subsidiary = create(:subsidiary)
        expect(subsidiary.parent.subsidiaries).to contain_exactly(subsidiary)
      end
    end
  end

  describe '#offices' do
    let(:firm) { create(:firm, offices_count: 0) }
    let!(:unsorted_offices) do
      [
        FactoryBot.create(:office, firm: firm, address_line_one: 'fourth', created_at: Time.zone.now),
        FactoryBot.create(:office, firm: firm, address_line_one: 'second', created_at: 2.days.ago),
        FactoryBot.create(:office, firm: firm, address_line_one: 'first',  created_at: 3.days.ago),
        FactoryBot.create(:office, firm: firm, address_line_one: 'third',  created_at: 1.day.ago)
      ]
    end

    describe 'default sort order' do
      subject { firm.reload.offices.map(&:address_line_one) }
      it { is_expected.to eq(%w{first second third fourth}) }
    end
  end

  describe '#main_office' do
    let(:firm) { create(:firm, offices_count: 0) }
    subject { firm.main_office }

    context 'when the firm has no offices' do
      it { is_expected.to be_nil }
    end

    context 'when the firm has offices' do
      before { FactoryBot.create_list(:office, 3, firm: firm) }
      # We implement using #first (which runs one query) but test against
      # offices[0]. Both should return the same value or things are not
      # correct.
      it { is_expected.to eq(firm.offices[0]) }
    end
  end

  describe '#publishable?' do
    let(:firm) { FactoryBot.create(:firm) }
    subject { firm.publishable? }

    context 'when the firm is valid, has a main office and is not missing advisers' do
      it { is_expected.to be_truthy }
    end

    context 'when the firm is not valid' do
      let(:firm) do
        FactoryBot.build(:invalid_firm).tap { |f| f.save(validate: false) }
      end

      it { is_expected.to be_falsey }
    end

    context 'when the firm has no main office' do
      let(:firm) { FactoryBot.create(:firm, offices_count: 0) }

      it { is_expected.to be_falsey }
    end

    context 'when the firm is missing advisers' do
      before { allow(firm).to receive(:missing_advisers?).and_return(true) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#missing_advisers?' do
    let(:factory) { :firm }
    subject { FactoryBot.create(factory, advisers_count: advisers_count).missing_advisers? }

    context 'when the firm offers face-to-face advice' do
      context 'when the firm has advisers' do
        let(:advisers_count) { 1 }
        it { is_expected.to be_falsey }
      end

      context 'when the firm has no advisers' do
        let(:advisers_count) { 0 }
        it { is_expected.to be_truthy }
      end
    end

    context 'when the firm offers remote advice' do
      let(:factory) { :firm_with_remote_advice }

      context 'when the firm has advisers' do
        let(:advisers_count) { 1 }
        it { is_expected.to be_falsey }
      end

      context 'when the firm has no advisers' do
        let(:advisers_count) { 0 }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe 'validation' do
    it 'is valid with valid attributes' do
      expect(firm).to be_valid
    end

    it 'orders fields correctly for dough' do
      expect(firm.field_order).not_to be_empty
    end

    describe 'Website address' do
      context 'when provided' do
        it 'must not exceed 100 characters' do
          expect(build(:firm, website_address: "#{'a' * 100}.com")).not_to be_valid
        end

        it 'must contain at least one .' do
          expect(build(:firm, website_address: 'http://examplecom')).not_to be_valid
          expect(build(:firm, website_address: 'http://example.com')).to be_valid
        end

        it 'must not contain spaces' do
          expect(build(:firm, website_address: 'http://example site.com')).not_to be_valid
        end

        it 'does not require the protocol to be present' do
          expect(build(:firm, website_address: 'www.example.com')).to be_valid
        end

        it 'must require the protocol to be http or https if provided' do
          expect(build(:firm, website_address: 'http://www.example.com')).to be_valid
          expect(build(:firm, website_address: 'https://www.example.com')).to be_valid
          expect(build(:firm, website_address: 'ftp://www.example.com')).not_to be_valid
        end

        it 'allows paths to be in the address' do
          expect(build(:firm, website_address: 'www.example.com/user')).to be_valid
        end
      end
    end

    describe 'languages' do
      context 'when it contains valid language strings' do
        before { firm.languages = ['fra', 'deu'] }
        it { is_expected.to be_valid }
      end

      context 'when it contains invalid language strings' do
        before { firm.languages = ['no_language', 'fra'] }
        it { is_expected.to be_invalid }
      end

      context 'when it is empty' do
        before { firm.languages = [] }
        it { is_expected.to be_valid }
      end

      context 'when it contains blank values' do
        before { firm.languages = [''] }
        it 'filters them out pre-validation' do
          firm.valid?
          expect(firm.languages).to be_empty
        end
      end

      context 'when it contains duplicate values' do
        before { firm.languages = ['fra', 'fra', 'deu'] }
        it 'filters them out pre-validation' do
          firm.valid?
          expect(firm.languages).to eq ['fra', 'deu']
        end
      end
    end

    describe 'in person advice methods' do
      # Make the record generally valid for either remote or local types vvv
      before { firm.other_advice_methods = create_list(:other_advice_method, rand(1..3)) }

      context 'when none assigned' do
        before { firm.in_person_advice_methods = [] }

        context 'when the user selects remote advice' do
          before { firm.primary_advice_method = :remote }
          it { is_expected.to be_valid }

          it 'clears in-person advice methods' do
            subject.valid?
            expect(subject.in_person_advice_methods).to be_empty
          end
        end

        context 'when the user selects local advice' do
          before { firm.primary_advice_method = :local }
          it { is_expected.not_to be_valid }

          it 'preserves remote advice methods' do
            subject.valid?
            expect(subject.other_advice_methods).to_not be_empty
          end
        end
      end
    end

    describe 'other (remote) advice methods' do
      context 'when none assigned' do
        before { firm.other_advice_methods = [] }

        context 'when the user selects remote advice' do
          before { firm.primary_advice_method = :remote }
          it { is_expected.not_to be_valid }
        end

        context 'when the user selects local advice' do
          before { firm.primary_advice_method = :local }
          it { is_expected.to be_valid }
        end
      end
    end

    describe 'remote or local advice method' do
      context 'when none assigned' do
        before { firm.other_advice_methods = [] }
        before { firm.in_person_advice_methods = [] }
        before { firm.primary_advice_method = nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'free initial meeting' do
      context 'when missing' do
        before { firm.free_initial_meeting = nil }

        it { is_expected.not_to be_valid }
      end

      context 'when set to true' do
        before { firm.free_initial_meeting = true }

        describe 'initial meeting duration' do
          before { firm.initial_meeting_duration = nil }

          context 'when missing' do
            it { is_expected.not_to be_valid }
          end
        end
      end
    end

    describe 'initial advice fee structures' do
      context 'when none assigned' do
        before { firm.initial_advice_fee_structures = [] }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'ongoing advice fee structures' do
      context 'when none assigned' do
        before { firm.ongoing_advice_fee_structures = [] }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'allowed payment methods' do
      context 'when none assigned' do
        before { firm.allowed_payment_methods = [] }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'minimum fixed fee' do
      context 'default value' do
        it { expect(Firm.new.minimum_fixed_fee).to eq(0) }
      end

      context 'when not numeric' do
        before { firm.minimum_fixed_fee = 'not-numeric' }

        it { is_expected.not_to be_valid }
      end

      context 'when blank' do
        before { firm.minimum_fixed_fee = nil }

        it { is_expected.not_to be_valid }
      end

      context 'when less than zero' do
        before { firm.minimum_fixed_fee = -1 }

        it { is_expected.to be_invalid }
      end

      context 'when zero' do
        before { firm.minimum_fixed_fee = 0 }

        it { is_expected.to be_valid }
      end

      context 'when more than zero' do
        before { firm.minimum_fixed_fee = 1 }

        it { is_expected.to be_valid }
      end
    end

    describe 'investment size' do
      context 'when none assigned' do
        before { firm.investment_sizes = [] }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'advice types' do
      context 'when none assigned' do
        before do
          Firm::ADVICE_TYPES_ATTRIBUTES.each do |attribute|
            firm[attribute] = false
          end
        end

        it { is_expected.not_to be_valid }
      end
    end

    describe 'status' do
      context 'without a status' do
        it 'is valid' do
          expect(build(:firm, status: nil)).to be_valid
        end
      end

      context 'with a garbage status' do
        it 'throws an exception' do
          expect { build(:firm, status: :horse) }.to raise_error(ArgumentError)
        end
      end

      context 'with status "independent"' do
        it 'is valid' do
          expect(build(:firm, status: :independent)).to be_valid
        end
      end

      context 'with status "restricted"' do
        it 'is valid' do
          expect(build(:firm, status: :restricted)).to be_valid
        end
      end
    end
  end

  describe '#notify_indexer' do
    it 'notifies the firm indexer that the firm has changed' do
      expect(FirmIndexer).to receive(:handle_firm_changed).with(subject)
      subject.notify_indexer
    end
  end

  describe 'after_commit' do
    before { expect(subject).to receive(:notify_indexer) }

    context 'when a new firm is saved' do
      subject { FactoryBot.build(:firm) }

      it 'calls notify_indexer' do
        subject.save
        subject.run_callbacks(:commit)
      end
    end

    context 'when a firm is updated' do
      subject { FactoryBot.create(:firm) }

      it 'calls notify_indexer' do
        subject.update_attributes(registered_name: 'A new name')
        subject.run_callbacks(:commit)
      end
    end

    context 'when a firm is destroyed' do
      subject { FactoryBot.create(:firm) }

      it 'calls notify_indexer' do
        firm.destroy
        subject.run_callbacks(:commit)
      end
    end
  end

  describe 'destruction' do
    context 'when the firm has advisers' do
      let(:firm) { create(:firm_with_advisers) }

      it 'cascades destroy to advisers' do
        adviser = firm.advisers.first
        firm.destroy
        expect(Adviser.where(id: adviser.id)).to be_empty
      end
    end

    context 'when the firm has subsidiaries' do
      let(:firm) { create(:firm_with_trading_names) }

      it 'cascades to destroy the subsidiaries too' do
        subsidiary = firm.subsidiaries.first
        firm.destroy
        expect(Firm.where(id: subsidiary.id)).to be_empty
      end
    end

    context 'when the firm has offices' do
      let(:firm) { create(:firm_with_offices, offices_count: 1) }

      it 'cascades to destroy the offices too' do
        office = firm.offices.first
        firm.destroy
        expect(Office.where(id: office.id)).to be_empty
      end
    end

    context 'when the firm has a principal' do
      let(:firm) { create(:firm_with_principal) }

      it 'does not destroy the principal' do
        principal = firm.principal
        firm.destroy
        expect(Principal.where(token: principal.id)).not_to be_empty
      end
    end
  end

  describe '.sorted_by_registered_name scope' do
    let(:sorted_names)   { %w(A B C D E F G H) }
    let(:unsorted_names) { %w(F C G E D H A B) }

    before do
      unsorted_names.each { |name| FactoryBot.create(:firm, registered_name: name) }
    end

    it 'sorts the result set by the registered_name field' do
      expect(Firm.sorted_by_registered_name.map(&:registered_name)).to eq(sorted_names)
    end
  end

  describe '#advice_types' do
    it 'returns a hash of advice types' do
      expect(subject.advice_types).to eq({
        retirement_income_products_flag: subject.retirement_income_products_flag,
        pension_transfer_flag: subject.pension_transfer_flag,
        long_term_care_flag: subject.long_term_care_flag,
        equity_release_flag: subject.equity_release_flag,
        inheritance_tax_and_estate_planning_flag: subject.inheritance_tax_and_estate_planning_flag,
        wills_and_probate_flag: subject.wills_and_probate_flag
      })
    end
  end

  describe '#remote_advice' do
    let(:firm) do
      FactoryBot.create(:firm,
                         in_person_advice_methods: in_person_advice_methods,
                         other_advice_methods: other_advice_methods)
    end
    subject { firm.primary_advice_method }
    let(:in_person_advice_methods) { [create(:in_person_advice_method)] }
    let(:other_advice_methods) { [] }

    context 'when instance variable is set' do
      before { firm.primary_advice_method = :dog }
      it { is_expected.to be :dog }
    end

    context 'when in-person advice methods are set' do
      let(:in_person_advice_methods) { FactoryBot.create_list :in_person_advice_method, 1 }

      context 'when remote advice methods are set' do
        let(:other_advice_methods) { FactoryBot.create_list :other_advice_method, 1 }
        it { is_expected.to be :local }
      end

      context 'when remote advice methods are not set' do
        it { is_expected.to be :local }
      end
    end

    context 'when in-person advice methods are not set' do
      context 'when remote advice methods are set' do
        let(:other_advice_methods) { FactoryBot.create_list :other_advice_method, 1 }
        let(:in_person_advice_methods) { [] }
        it { is_expected.to be :remote }
      end

      context 'when remote advice methods are not set' do
        before { firm.in_person_advice_methods = [] }
        it { is_expected.to be nil }
      end
    end
  end
end
