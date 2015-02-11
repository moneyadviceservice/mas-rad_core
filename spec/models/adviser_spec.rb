RSpec.describe Adviser do
  describe 'before validation' do
    context 'when a reference number is present' do
      let(:attributes) { attributes_for(:adviser) }
      let(:adviser) { Adviser.new(attributes) }

      before do
        Lookup::Adviser.create!(
          reference_number: attributes[:reference_number],
          name: 'Mr. Welp'
        )
      end

      it 'assigns #name from the lookup Adviser data' do
        adviser.validate

        expect(adviser.name).to eq('Mr. Welp')
      end
    end
  end

  describe 'validation' do
    it 'is valid with valid attributes' do
      expect(build(:adviser)).to be_valid
    end

    it 'orders fields correctly for dough' do
      expect(build(:adviser).field_order).not_to be_empty
    end

    describe 'geographical coverage' do
      describe 'travel distance' do
        it 'must be provided' do
          expect(build(:adviser, travel_distance: nil)).to_not be_valid
        end

        it 'must be within the allowed options' do
          expect(build(:adviser, travel_distance: 999)).to_not be_valid
        end
      end

      describe 'postcode' do
        it 'must be provided' do
          expect(build(:adviser, postcode: nil)).to_not be_valid
        end

        it 'must be a valid format' do
          expect(build(:adviser, postcode: '098abc')).to_not be_valid
        end
      end
    end

    describe 'statement of truth' do
      it 'must be confirmed' do
        expect(build(:adviser, confirmed_disclaimer: false)).to_not be_valid
      end
    end

    describe 'reference number' do
      it 'is required' do
        expect(build(:adviser, reference_number: nil)).to_not be_valid
      end

      it 'must be three characters and five digits exactly' do
        %w(badtimes ABCDEFGH 8008135! 12345678).each do |bad|
          Lookup::Adviser.create!(reference_number: bad, name: 'Mr. Derp')

          expect(build(:adviser, reference_number: bad)).to_not be_valid
        end
      end

      it 'must be matched to the lookup data' do
        build(:adviser, reference_number: 'ABC12345').tap do |a|
          Lookup::Adviser.delete_all

          expect(a).to_not be_valid
        end
      end

      context 'when an adviser with the same reference number already exists' do
        let(:reference_number) { 'ABC12345' }

        before do
          create(:adviser, reference_number: reference_number)
        end

        it 'must not be valid' do
          expect(build(:adviser, reference_number: reference_number)).to_not be_valid
        end
      end
    end
  end
end
