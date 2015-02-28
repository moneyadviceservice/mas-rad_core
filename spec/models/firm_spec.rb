RSpec.describe Firm do
  subject(:firm) { build(:firm) }

  before { allow(GeocodeFirmJob).to receive(:perform_later) }

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

  describe '#full_street_address_changed?' do
    context 'with an existing firm' do
      before { subject.save }

      it { is_expected.to_not be_full_street_address_changed }

      context 'when the first line of the address has changed' do
        before { firm.address_line_one = 'changed' }
        it { is_expected.to be_full_street_address_changed }
      end

      context 'when the second line of the address has changed' do
        before { firm.address_line_two = 'changed' }
        it { is_expected.to be_full_street_address_changed }
      end

      context 'when the address postcode has changed' do
        before { firm.address_postcode = 'changed' }
        it { is_expected.to be_full_street_address_changed }
      end
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
        firm.save!
      end
    end

    context 'when the firm is not valid' do
      before { firm.address_line_one = nil }

      it 'the firm is not scheduled for geocoding' do
        expect(GeocodeFirmJob).not_to receive(:perform_later)
        firm.save!(validate: false)
      end
    end

    context 'when the address has changed' do
      let(:firm) { create(:firm) }

      before { firm.address_postcode = 'ABCD 123' }

      it 'the firm is scheduled for geocoding' do
        expect(GeocodeFirmJob).to receive(:perform_later).with(firm)
        firm.save!
      end
    end
  end
end
