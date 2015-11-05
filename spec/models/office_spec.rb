RSpec.describe Office do
  include FieldLengthValidationHelpers

  let(:firm) { FactoryGirl.create(:firm_with_offices, id: 123) }
  subject(:office) { firm.offices.first }

  it_should_behave_like 'geocodable' do
    let(:job_class) { double }
  end

  describe '#geocode' do
    context 'when the subject is not valid' do
      subject { Office.new }

      it 'does not call the geocoder' do
        expect(ModelGeocoder).not_to receive(:geocode)
        subject.geocode
      end

      it 'returns false' do
        expect(subject.geocode).to be(false)
      end
    end

    context 'when the subject is valid' do
      subject { FactoryGirl.build(:office, firm: firm) }

      context 'when the subject does not need to be geocoded' do
        before do
          allow(subject).to receive(:needs_to_be_geocoded?).and_return(false)
        end

        it 'does not call the geocoder' do
          expect(ModelGeocoder).not_to receive(:geocode)
          subject.geocode
        end

        it 'returns true' do
          expect(subject.geocode).to be(true)
        end
      end

      context 'when the subject needs to be geocoded' do
        before do
          allow(subject).to receive(:needs_to_be_geocoded?).and_return(true)
        end

        it 'calls the geocoder passing itself' do
          expect(ModelGeocoder).to receive(:geocode).with(subject)
          subject.geocode
        end

        context 'when geocoding succeeds' do
          before do
            allow(ModelGeocoder).to receive(:geocode).and_return([1.0, 1.0])
          end

          it 'returns true' do
            expect(subject.geocode).to be(true)
          end
        end

        context 'when geocoding fails' do
          before do
            allow(ModelGeocoder).to receive(:geocode).and_return(nil)
          end

          it 'returns false' do
            expect(subject.geocode).to be(false)
          end
        end
      end
    end
  end

  describe '#needs_to_be_geocoded?' do
    context 'when the model has not been geocoded' do
      before do
        expect(subject).not_to be_geocoded
      end

      it 'returns true' do
        expect(subject.needs_to_be_geocoded?).to be(true)
      end
    end

    context 'when the model has been geocoded' do
      before do
        subject.update_coordinates!([1.0, 1.0])
        expect(subject).to be_geocoded
      end

      context 'when the model address fields have not changed' do
        before do
          expect(subject).not_to have_address_changes
        end

        it 'returns false' do
          expect(subject.needs_to_be_geocoded?).to be(false)
        end
      end

      context 'when the model address fields have changed' do
        before do
          subject.address_postcode = 'SO31 2AY'
          expect(subject).to have_address_changes
        end

        it 'returns true' do
          expect(subject.needs_to_be_geocoded?).to be(true)
        end
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

  describe '#save_with_geocoding' do
    before { allow(office).to receive(:geocode).and_return(result_of_geocoding) }
    subject { office.save_with_geocoding }

    context 'when geocoding fails' do
      let(:result_of_geocoding) { false }

      it { is_expected.to be(false) }

      it 'does not call save' do
        expect(office).not_to receive(:save)
        subject
      end
    end

    context 'when geocoding succeeds' do
      let(:result_of_geocoding) { true }
      let(:result_of_saving) { true }
      before { allow(office).to receive(:save).and_return(result_of_saving) }

      it 'calls save' do
        expect(office).to receive(:save)
        subject
      end

      context 'when saving fails' do
        let(:result_of_saving) { false }
        it { is_expected.to be(false) }
      end

      context 'when saving succeeds' do
        it { is_expected.to be(true) }
      end
    end
  end

  describe '#update_with_geocoding' do
    subject { office.update_with_geocoding(address_line_one: '123 xyz street') }

    it 'updates the office with new attributes' do
      allow(office).to receive(:save_with_geocoding)
      subject
      expect(office.changed_attributes).to include(:address_line_one)
    end

    it 'calls #save_with_geocoding' do
      expect(office).to receive(:save_with_geocoding)
      subject
    end

    it 'returns the return value of #save_with_geocoding' do
      allow(office).to receive(:save_with_geocoding).and_return(:return_marker)
      expect(subject).to eq(:return_marker)
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
