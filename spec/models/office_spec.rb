RSpec.describe Office do
  subject(:office) { FactoryGirl.build(:office) }

  describe 'validation' do
    it 'is valid with valid attributes' do
      expect(office).to be_valid
    end

    it 'orders fields correctly for dough' do
      expect(office.field_order).not_to be_empty
    end

    describe 'email address' do
      context 'when not present' do
        before { office.email_address = nil }

        it { is_expected.to_not be_valid }
      end

      context 'when badly formatted' do
        before { office.email_address = 'not-valid' }

        it { is_expected.to_not be_valid }
      end
    end

    describe 'telephone number' do
      context 'when not present' do
        before { office.telephone_number = nil }

        it { is_expected.to_not be_valid }
      end

      context 'when badly formatted' do
        before { office.telephone_number = 'not-valid' }

        it { is_expected.to_not be_valid }
      end
    end

    describe 'address line 1' do
      context 'when missing' do
        before { office.address_line_one = nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'address town' do
      context 'when missing' do
        before { office.address_town = nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'address county' do
      context 'when missing' do
        before { office.address_county = nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'address postcode' do
      context 'when missing' do
        before { office.address_postcode = nil }

        it { is_expected.not_to be_valid }
      end

      context 'when invalid' do
        before { office.address_postcode = 'not-valid' }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'disabled access' do
      context 'when missing' do
        before { office.disabled_access = nil }

        it { is_expected.not_to be_valid }
      end

      context 'when true' do
        before { office.disabled_access = true }

        it { is_expected.to be_valid }
      end

      context 'when false' do
        before { office.disabled_access = false }

        it { is_expected.to be_valid }
      end
    end
  end
end
