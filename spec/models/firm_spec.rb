RSpec.describe Firm do
  subject(:firm) { build(:firm) }

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
end
