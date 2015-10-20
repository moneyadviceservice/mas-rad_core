RSpec.describe FirmResult do
  let(:data) do
    {
      '_index'  => 'rad_test',
      '_type'   => 'firms',
      '_id'     => '1',
      '_score'  => nil,
      '_source' => {
        '_id' => 1,
        'registered_name' => 'Financial Advice 1 Ltd.',
        'postcode_searchable' => true,
        'address_line_one' => '64 Somewhere',
        'address_line_two' => 'At this place',
        'address_town' => 'Romford',
        'address_county' => 'Essex',
        'address_postcode' => 'RM1 1AL',
        'telephone_number' => '02085952346',
        'website_address' => 'http://www.example.com',
        'email_address' => 'someone@example.com',
        'free_initial_meeting' => true,
        'minimum_fixed_fee' => 999,
        'other_advice_methods' => [1, 2, 3],
        'in_person_advice_methods' => [1, 2, 3],
        'retirement_income_products' => 10,
        'pension_transfer' => 10,
        'options_when_paying_for_care' => 10,
        'equity_release' => 10,
        'inheritance_tax_planning' => 10,
        'wills_and_probate' => 0,
        'investment_sizes' => [1, 2],
        'adviser_accreditation_ids' => [5],
        'adviser_qualification_ids' => [3],
        'advisers' => [
          {
            '_id'      => 1,
            'name'     => 'Ben Lovell',
            'range'    => 50,
            'location' => { 'lat' => 51.428473, 'lon' => -0.943616 }
          }
        ]
      },
      'sort' => [0.7794549719530739]
    }
  end

  subject { described_class.new(data) }

  describe 'the deserialized result' do
    it 'maps the `id`' do
      expect(subject.id).to eq(1)
    end

    it 'maps the `name`' do
      expect(subject.name).to eq('Financial Advice 1 Ltd.')
    end

    it 'maps the `address_line_one`' do
      expect(subject.address_line_one).to eq('64 Somewhere')
    end

    it 'maps the `address_line_two`' do
      expect(subject.address_line_two).to eq('At this place')
    end

    it 'maps the `address_town`' do
      expect(subject.address_town).to eq('Romford')
    end

    it 'maps the `address_county`' do
      expect(subject.address_county).to eq('Essex')
    end

    it 'maps the `address_postcode`' do
      expect(subject.address_postcode).to eq('RM1 1AL')
    end

    it 'maps the `website_address`' do
      expect(subject.website_address).to eq('http://www.example.com')
    end

    it 'maps the `email_address`' do
      expect(subject.email_address).to eq('someone@example.com')
    end

    it 'maps the `free_initial_meeting`' do
      expect(subject.free_initial_meeting).to eq(true)
    end

    it 'maps the `minimum_fixed_fee`' do
      expect(subject.minimum_fixed_fee).to eq(999)
    end

    it 'maps the `other_advice_methods`' do
      expect(subject.other_advice_methods).to eq([1, 2, 3])
    end

    it 'maps the `in_person_advice_methods`' do
      expect(subject.in_person_advice_methods).to eq([1, 2, 3])
    end

    it 'maps the `total_advisers`' do
      expect(subject.total_advisers).to eq(1)
    end

    it 'maps the `types_of_advice` that are greater than 0 percent' do
      expect(subject.types_of_advice).to eq(
        FirmResult::TYPES_OF_ADVICE_FIELDS - [:wills_and_probate]
      )
    end

    it 'maps the `minimum_pot_size_id`' do
      expect(subject.minimum_pot_size_id).to eq(1)
    end

    it 'has a #minimum_fixed_fee?' do
      expect(subject).to be_minimum_fixed_fee
    end

    it 'has a #free_initial_meeting?' do
      expect(subject).to be_free_initial_meeting
    end

    it 'exposes `adviser_accreditation_ids`' do
      expect(subject.adviser_accreditation_ids).to eq([5])
    end

    it 'exposes `adviser_qualification_ids`' do
      expect(subject.adviser_qualification_ids).to eq([3])
    end

    describe '#advisers' do
      it 'returns an array containing the advisers' do
        expect(subject.advisers).to be_an(Array)
        expect(subject.advisers.length).to eq(1)
      end

      it 'returns AdviserResult objects' do
        expect(subject.advisers.first).to be_an(AdviserResult)
      end
    end

    describe '#minimum_pot_size?' do
      context 'when £50k or less' do
        it 'is false' do
          expect(subject).to_not be_minimum_pot_size
        end
      end
    end

    describe '#telephone_number' do
      context 'when present' do
        it 'correctly formatted' do
          expect(subject.telephone_number).to eq('020 8595 2346')
        end
      end
    end

    describe '#closest_adviser' do
      let(:text) { 'less than a mile away' }

      before do
        I18n.backend.store_translations :en,
          search: { result: { miles_away_alt: text, miles_away: 'miles away' } }
      end

      context 'when it is less than 1 mile away' do
        it 'returns `less than a mile away` localised text' do
          expect(subject.closest_adviser).to eq(text)
        end
      end

      context 'when it is a mile away or more' do
        before { data['sort'] = [1.23456789] }

        it 'returns the formatted distance' do
          expect(subject.closest_adviser).to eq('1.2 miles away')
        end
      end
    end

    describe 'includes_advice_type?' do
      let(:data) { { 'sort' => [1], '_source' => { 'advisers' => [], key => value } } }

      FirmResult::TYPES_OF_ADVICE_FIELDS.each do |advice_type|
        describe "attribute [#{advice_type}]" do
          let(:key) { advice_type.to_s }

          context 'has a value of 0 (false)' do
            let(:value) { 0 }

            it 'returns false' do
              expect(subject.includes_advice_type?(key)).to eq(false)
            end
          end

          context 'has a value of 100 (true)' do
            let(:value) { 100 }

            it 'returns true' do
              expect(subject.includes_advice_type?(key)).to eq(true)
            end
          end
        end
      end
    end
  end
end
