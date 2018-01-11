RSpec.describe Office do
  include FieldLengthValidationHelpers

  let(:firm) { FactoryBot.create(:firm_with_offices, id: 123) }
  subject(:office) { firm.offices.first }

  it_should_behave_like 'geocodable' do
    let(:invalid_geocodable) { Office.new }
    let(:valid_new_geocodable) { FactoryBot.build(:office, firm: firm) }
    let(:saved_geocodable) { office }
    let(:address_field_name) { :address_postcode }
    let(:address_field_updated_value) { 'SO32 2AY' }
    let(:updated_address_params) { { address_line_one: 'A new place' } }
  end

  describe '#notify_indexer' do
    it 'notifies the indexer that the office has changed' do
      expect(FirmIndexer).to receive(:handle_aggregate_changed).with(subject)
      subject.notify_indexer
    end
  end

  describe 'after_commit' do
    before { expect(subject).to receive(:notify_indexer) }

    context 'when a new office is saved' do
      subject { FactoryBot.build(:office, firm: firm) }

      it 'calls notify_indexer' do
        subject.save
        subject.run_callbacks(:commit)
      end
    end

    context 'when an office is updated' do
      it 'calls notify_indexer' do
        subject.update_attributes(address_line_one: 'A new street')
        subject.run_callbacks(:commit)
      end
    end

    context 'when an office is destroyed' do
      it 'calls notify_indexer' do
        office.destroy
        subject.run_callbacks(:commit)
      end
    end
  end

  describe '#has_address_changes?' do
    context 'when none of the address fields have changed' do
      it 'returns false' do
        expect(subject.has_address_changes?).to be(false)
      end
    end

    described_class::ADDRESS_FIELDS.each do |field|
      context "when the model #{field} field has changed" do
        before do
          subject.send("#{field}=", 'changed')
        end

        it 'returns true' do
          expect(subject.has_address_changes?).to be(true)
        end
      end
    end
  end

  describe '#telephone_number=' do
    context 'when `nil`' do
      before { office.telephone_number = nil }

      it 'returns `nil`' do
        expect(office.telephone_number).to be_nil
      end
    end

    context 'when provided' do
      it 'removes whitespace from the front and back' do
        office.telephone_number = ' 07715 930 457  '
        expect(office.telephone_number).to eq('07715 930 457')
      end

      it 'removes extraneous whitespace' do
        office.telephone_number = '07715    930    457'
        expect(office.telephone_number).to eq('07715 930 457')
      end
    end
  end

  describe '#telephone_number' do
    context 'when `nil`' do
      before { office.telephone_number = nil }

      it 'returns `nil`' do
        expect(office.telephone_number).to be_nil
      end
    end

    context 'when provided' do
      it 'removes whitespace from the front and back' do
        office.update_column(:telephone_number, ' 07715 930 457  ')
        expect(office.telephone_number).to eq('07715 930 457')
      end

      it 'removes extraneous whitespace' do
        office.update_column(:telephone_number, '07715    930    457')
        expect(office.telephone_number).to eq('07715 930 457')
      end

      it 'formats if there is no whitespace at all' do
        office.update_column(:telephone_number, '07715930457')
        expect(office.telephone_number).to eq('07715 930457')
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
      # See http://www.area-codes.org.uk/formatting.php#programmers for background info

      context 'invalid inputs' do
        context 'when not present' do
          before { office.telephone_number = nil }

          it { is_expected.to_not be_valid }
        end

        context 'when the input characters other than spaces or numbers' do
          before { office.telephone_number = 'not-numbers-or-spaces' }

          it { is_expected.to_not be_valid }
        end

        context 'when the area code is not specified' do
          before { office.telephone_number = '917561' }

          it { is_expected.to_not be_valid }
        end

        context 'when the prefix is not a 0' do
          before { office.telephone_number = '7816917560' }

          it { is_expected.to_not be_valid }
        end

        context 'when the prefix is not a real area code' do
          # Currently 04 and 06 are not valid prefixes
          before { office.telephone_number = '04816 917560' }

          it { is_expected.to_not be_valid }
        end

        context 'when the prefix is a +nn country code' do
          before { office.telephone_number = '+44 7816917560' }

          it { is_expected.to_not be_valid }
        end

        context 'when the prefix is a 00nn international access code' do
          before { office.telephone_number = '0044 7816917560' }

          it { is_expected.to_not be_valid }
        end

        context 'when the prefix is a nn international access code' do
          before { office.telephone_number = '447816917560' }

          it { is_expected.to_not be_valid }
        end
      end

      context 'valid inputs' do
        context 'when it has no spaces' do
          before { office.telephone_number = '07816917561' }

          it { is_expected.to be_valid }
        end

        context 'when it has spaces' do
          before { office.telephone_number = '07816 917 561' }

          it { is_expected.to be_valid }
        end
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
        before { office.address_postcode = 'eh3 9dr' }

        it 'upcases it before saving' do
          expect(office).to be_valid
          office.save!
          expect(office.address_postcode).to eq('EH3 9DR')
        end
      end

      context 'when not in the correct format' do
        it 'corrects the format before saving' do
          office.address_postcode = 'EH39DR'
          expect(office).to be_valid
          office.save!
          expect(office.address_postcode).to eq('EH3 9DR')
        end
      end

      context 'format' do
        it 'is invalid without a full postcode' do
          office.address_postcode = 'W12'
          expect(office).to be_invalid
          expect(office.errors[:address_postcode]).to include('is invalid')
        end

        it 'is invalid with an invalid full postcode' do
          office.address_postcode = '1234 567'
          expect(office).to be_invalid
          expect(office.errors[:address_postcode]).to include('is invalid')
          expect(office.address_postcode).to eq('1234 567')
        end

        it 'is valid with a valid full postcode' do
          office.address_postcode = 'EH3 9DR'
          expect(office).to be_valid
        end

        it 'is valid with a valid full postcode even without spaces' do
          office.address_postcode = 'EH39DR'
          expect(office).to be_valid
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

    it { is_expected.to eql "#{office.address_postcode}, United Kingdom"}

    context 'when line two is nil' do
      before { office.address_line_two = nil }

      it { is_expected.to eql "#{office.address_postcode}, United Kingdom"}
    end

    context 'when line two is an empty string' do
      before { office.address_line_two = '' }

      it { is_expected.to eql "#{office.address_postcode}, United Kingdom"}
    end
  end
end
