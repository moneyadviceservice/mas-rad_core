RSpec.describe Firm do
  subject(:firm) { build(:firm) }

  before { allow(GeocodeFirmJob).to receive(:perform_later) }

  describe 'default behaviour' do
    it 'sets ethical_investing_flag to false' do
      expect(Firm.new.ethical_investing_flag).to be_falsey
    end

    it 'sets sharia_investing_flag to false' do
      expect(Firm.new.sharia_investing_flag).to be_falsey
    end

    it 'sets languages to an array with empty set' do
      expect(Firm.new.languages).to eq []
    end
  end

  describe '#registered?' do
    it 'is false if the firm has no email address' do
      firm.email_address = nil
      expect(firm).not_to be_registered
    end

    it 'is true if the firm has an email address' do
      firm.email_address = 'acme@example.com'
      expect(firm).to be_registered
    end
  end

  describe '#telephone_number' do
    context 'when `nil`' do
      it 'returns `nil`' do
        expect(build(:firm, telephone_number: nil).telephone_number).to be_nil
      end
    end

    context 'when provided' do
      let(:firm) { build(:firm, telephone_number: ' 07715 930 457  ') }

      it 'removes whitespace' do
        expect(firm.telephone_number).to eq('07715930457')
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
        FactoryGirl.create(:office, firm: firm, address_line_one: 'fourth', created_at: Time.zone.now),
        FactoryGirl.create(:office, firm: firm, address_line_one: 'second', created_at: 2.days.ago),
        FactoryGirl.create(:office, firm: firm, address_line_one: 'first',  created_at: 3.days.ago),
        FactoryGirl.create(:office, firm: firm, address_line_one: 'third',  created_at: 1.day.ago)
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
      before { FactoryGirl.create_list(:office, 3, firm: firm) }
      # We implement using #first (which runs one query) but test against
      # offices[0]. Both should return the same value or things are not
      # correct.
      it { is_expected.to eq(firm.offices[0]) }
    end
  end

  describe '#publishable?' do
    subject { create(:firm, offices_count: offices_count) }

    context 'when the firm has no main office' do
      let(:offices_count) { 0 }
      it { expect(subject).not_to be_publishable }
    end

    context 'when the firm has a main office' do
      let(:offices_count) { 1 }
      it { expect(subject).to be_publishable }
    end
  end

  describe 'validation' do
    it 'is valid with valid attributes' do
      expect(firm).to be_valid
    end

    it 'orders fields correctly for dough' do
      expect(firm.field_order).not_to be_empty
    end

    describe 'email address' do
      context 'when not present' do
        before { firm.email_address = nil }

        it { is_expected.to_not be_valid }
      end

      context 'when badly formatted' do
        before { firm.email_address = 'not-valid' }

        it { is_expected.to_not be_valid }
      end
    end

    describe 'telephone number' do
      context 'when not present' do
        before { firm.telephone_number = nil }

        it { is_expected.to_not be_valid }
      end

      context 'when badly formatted' do
        before { firm.telephone_number = 'not-valid' }

        it { is_expected.to_not be_valid }
      end
    end

    describe 'Website address' do
      context 'when provided' do
        it 'must not exceed 100 characters' do
          expect(build(:firm, website_address: "#{'a' * 100}.com")).not_to be_valid
        end

        it 'must include the protocol segment' do
          expect(build(:firm, website_address: 'www.google.com')).not_to be_valid
        end

        it 'must be a reasonably valid URL' do
          expect(build(:firm, website_address: 'http://a')).not_to be_valid
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
      context 'when not numeric' do
        before { firm.minimum_fixed_fee = 'not-numeric' }

        it { is_expected.not_to be_valid }
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
        it 'is not valid' do
          expect(build(:firm, status: nil)).to_not be_valid
        end
      end

      context 'with a garbage status' do
        it 'throws an exception' do
          expect { build(:firm, status: :horse) }.to raise_error
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

  it_should_behave_like 'geocodable' do
    subject(:firm) { create(:firm) }
    let(:job_class) { GeocodeFirmJob }
  end

  describe '#geocode_and_reindex' do
    # does the reindexing inside the GeocodeFirmJob, tests for that are there

    it 'performs a geocode firm job' do
      firm.geocode_and_reindex
      expect(GeocodeFirmJob).to have_received(:perform_later).with(firm)
    end

    it 'does not perform a geocode firm job when the firm has been destroyed' do
      firm.destroy
      firm.geocode_and_reindex
      expect(GeocodeFirmJob).not_to have_received(:perform_later).with(firm)
    end
  end

  describe 'after_commit:publish_firm' do
    context 'when a firm is created' do
      it 'the firm is published' do
        allow(IndexFirmJob).to receive(:perform_later)
        firm = create :firm
        firm.run_callbacks(:commit)
        expect(IndexFirmJob).to have_received(:perform_later).with(firm)
      end
    end

    context 'when a firm is updated' do
      it 'the firm is published' do
        firm = create :firm
        allow(IndexFirmJob).to receive(:perform_later)
        firm.update_attributes(email_address: 'bill@example.com')
        firm.run_callbacks(:commit)
        expect(IndexFirmJob).to have_received(:perform_later).with(firm)
      end
    end

    context 'when a firm is destroyed' do
      it 'the firm is not published' do
        firm = create :firm
        allow(IndexFirmJob).to receive(:perform_later)
        firm.destroy
        expect(IndexFirmJob).not_to have_received(:perform_later)
      end
    end
  end

  describe 'destroying' do
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

    describe 'deleting in elastic search' do
      let(:firm) do
        create(:firm,
               :with_offices,
               :with_advisers,
               :with_principal,
               offices_count: 1,
               advisers_count: 1)
      end

      context 'when the firm is destroyed' do
        it 'the firm is scheduled for deletion' do
          expect(DeleteFirmJob).to receive(:perform_later).with(firm.id)
          firm.destroy
          firm.run_callbacks(:commit)
        end

        it 'does not trigger geocoding of the firm' do
          expect(GeocodeFirmJob).not_to receive(:perform_later)
          adviser = firm.advisers.first
          office = firm.offices.first
          firm.destroy
          adviser.run_callbacks(:commit)
          office.run_callbacks(:commit)
          firm.run_callbacks(:commit)
        end
      end

      context 'when the firm is not destroyed' do
        it 'the firm is not scheduled for deletion' do
          expect(DeleteFirmJob).not_to receive(:perform_later).with(firm.id)
          firm.run_callbacks(:commit)
        end
      end
    end
  end

  describe '.sorted_by_registered_name scope' do
    let(:sorted_names)   { %w(A B C D E F G H) }
    let(:unsorted_names) { %w(F C G E D H A B) }

    before do
      unsorted_names.each { |name| FactoryGirl.create(:firm, registered_name: name) }
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
      FactoryGirl.create(:firm,
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
      let(:in_person_advice_methods) { FactoryGirl.create_list :in_person_advice_method, 1 }

      context 'when remote advice methods are set' do
        let(:other_advice_methods) { FactoryGirl.create_list :other_advice_method, 1 }
        it { is_expected.to be :local }
      end

      context 'when remote advice methods are not set' do
        it { is_expected.to be :local }
      end
    end

    context 'when in-person advice methods are not set' do
      context 'when remote advice methods are set' do
        let(:other_advice_methods) { FactoryGirl.create_list :other_advice_method, 1 }
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
