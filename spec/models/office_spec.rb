RSpec.describe Office do
  include FieldLengthValidationHelpers

  let(:firm) { FactoryGirl.create(:firm_with_offices, id: 123) }
  subject(:office) { firm.offices.first }

  it_should_behave_like 'geocodable' do
    let(:job_class) { double }
  end

  describe '#telephone_number' do
    context 'when `nil`' do
      before { office.telephone_number = nil }

      it 'returns `nil`' do
        expect(office.telephone_number).to be_nil
      end
    end

    context 'when provided' do
      before { office.telephone_number = ' 07715 930 457  ' }

      it 'removes whitespace' do
        expect(office.telephone_number).to eq('07715930457')
      end
    end
  end

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

      context 'length' do
        specify { expect_length_of(office, :email_address, 50).to be_valid }
        specify { expect_length_of(office, :email_address, 51).not_to be_valid }
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

      context 'length' do
        specify { expect_length_of(office, :telephone_number, 30, fill_char: '0').to be_valid }
        specify { expect_length_of(office, :telephone_number, 31, fill_char: '0').not_to be_valid }
      end
    end

    describe 'address line 1' do
      context 'when missing' do
        before { office.address_line_one = nil }

        it { is_expected.not_to be_valid }
      end

      context 'length' do
        specify { expect_length_of(office, :address_line_one, 100).to be_valid }
        specify { expect_length_of(office, :address_line_one, 101).not_to be_valid }
      end
    end

    describe 'address town' do
      context 'when missing' do
        before { office.address_town = nil }

        it { is_expected.not_to be_valid }
      end

      context 'length' do
        specify { expect_length_of(office, :address_town, 100).to be_valid }
        specify { expect_length_of(office, :address_town, 101).not_to be_valid }
      end
    end

    describe 'address county' do
      context 'when missing' do
        before { office.address_county = nil }

        it { is_expected.to be_valid }
      end

      context 'length' do
        specify { expect_length_of(office, :address_county, 100).to be_valid }
        specify { expect_length_of(office, :address_county, 101).not_to be_valid }
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

      context 'when not all upper cased' do
        before { office.address_postcode.downcase! }

        it 'upcases it before validating' do
          expect(office).to be_valid
          expect(office.address_postcode).to eq(office.address_postcode.upcase)
        end
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

  describe '#full_street_address' do
    subject { office.full_street_address }

    it { is_expected.to eql "#{office.address_line_one}, #{office.address_line_two}, #{office.address_postcode}, United Kingdom"}

    context 'when line two is nil' do
      before { office.address_line_two = nil }

      it { is_expected.to eql "#{office.address_line_one}, #{office.address_postcode}, United Kingdom"}
    end

    context 'when line two is an empty string' do
      before { office.address_line_two = '' }

      it { is_expected.to eql "#{office.address_line_one}, #{office.address_postcode}, United Kingdom"}
    end
  end
end
