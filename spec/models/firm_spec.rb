RSpec.describe Firm do
  subject(:firm) { build(:firm) }

  before { allow(GeocodeFirmJob).to receive(:perform_later) }

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

    describe 'address line 1' do
      context 'when missing' do
        before { firm.address_line_one = nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'address town' do
      context 'when missing' do
        before { firm.address_town = nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'address county' do
      context 'when missing' do
        before { firm.address_county = nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'address postcode' do
      context 'when missing' do
        before { firm.address_postcode = nil }

        it { is_expected.not_to be_valid }
      end

      context 'when invalid' do
        before { firm.address_postcode = nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'in person advice methods' do
      context 'when none assigned' do
        before { firm.in_person_advice_methods = [] }

        it { is_expected.to be_valid }
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

    describe 'business income breakdown' do
      context 'when sum not equal to 100' do
        before do
          firm.retirement_income_products_percent = 5
        end

        it { is_expected.not_to be_valid }
      end
    end

    describe 'investment size' do
      context 'when none assigned' do
        before { firm.investment_sizes = [] }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe '#full_street_address' do
    subject { firm.full_street_address }

    it { is_expected.to eql "#{firm.address_line_one}, #{firm.address_line_two}, #{firm.address_postcode}, United Kingdom"}

    context 'when line two is nil' do
      before { firm.address_line_two = nil }

      it { is_expected.to eql "#{firm.address_line_one}, #{firm.address_postcode}, United Kingdom"}
    end

    context 'when line two is an empty string' do
      before { firm.address_line_two = '' }

      it { is_expected.to eql "#{firm.address_line_one}, #{firm.address_postcode}, United Kingdom"}
    end
  end

  it_should_behave_like 'geocodable' do
    subject(:firm) { create(:firm) }
    let(:job_class) { GeocodeFirmJob }
  end

  describe 'geocoding' do
    context 'when the address is present' do
      it 'the firm is scheduled for geocoding' do
        expect(GeocodeFirmJob).to receive(:perform_later).with(firm)
        firm.run_callbacks(:commit)
      end
    end

    context 'when the firm is not valid' do
      before { firm.address_line_one = nil }

      it 'the firm is not scheduled for geocoding' do
        expect(GeocodeFirmJob).not_to receive(:perform_later)
        firm.run_callbacks(:commit)
      end
    end

    context 'when the address has changed' do
      let(:firm) { create(:firm) }

      before { firm.address_postcode = 'ABCD 123' }

      it 'the firm is scheduled for geocoding' do
        expect(GeocodeFirmJob).to receive(:perform_later).with(firm)
        firm.run_callbacks(:commit)
      end
    end
  end

  describe 'destroying' do
    context 'when the firm has advisers' do
      let(:firm) { create(:firm_with_advisers) }

      it 'cascades destroy to advisers' do
        adviser = firm.advisers.first
        firm.destroy
        firm.run_callbacks(:commit)
        adviser.run_callbacks(:commit)
        expect(Adviser.where(id: adviser.id)).to be_empty
      end

      it 'does not geocode the firm' do
        expect(GeocodeFirmJob).not_to receive(:perform_later)
        adviser = firm.advisers.first
        firm.destroy
        firm.run_callbacks(:commit)
        adviser.run_callbacks(:commit)
      end
    end

    context 'when the firm has subsidiaries' do
      let(:firm) { create(:firm_with_subsidiaries) }

      it 'cascades destroy to subsidiaries' do
        subsidiary = firm.subsidiaries.first
        firm.destroy
        firm.run_callbacks(:commit)
        expect(Firm.where(id: subsidiary.id)).to be_empty
      end
    end

    context 'when the firm has a principal' do
      let(:firm) { create(:firm_with_principal) }

      it 'does not destroy the principal' do
        principal = firm.principal
        firm.destroy
        firm.run_callbacks(:commit)
        expect(Principal.where(token: principal.id)).not_to be_empty
      end
    end

    describe 'deleting in elastic search' do
      context 'when the firm is destroyed' do
        it 'the firm is scheduled for deletion' do
          expect(DeleteFirmJob).to receive(:perform_later).with(firm.id)
          firm.destroy
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
end
