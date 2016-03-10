RSpec.describe AdviserSerializer do
  let(:adviser) { create(:adviser) }

  describe 'the serialized json' do
    subject { described_class.new(adviser).as_json }

    it 'exposes `_id`' do
      expect(subject[:_id]).to eql(adviser.id)
    end

    it 'exposes `name`' do
      expect(subject[:name]).to eql(adviser.name)
    end

    it 'exposes `postcode`' do
      expect(subject[:postcode]).to eql(adviser.postcode)
    end

    it 'exposes `range`' do
      expect(subject[:range]).to eql(adviser.travel_distance)
    end

    it 'exposes `location`' do
      expect(subject[:location][:lat]).to eql(adviser.latitude)
      expect(subject[:location][:lon]).to eql(adviser.longitude)
    end

    it 'exposes `range_location`' do
      expect(subject[:range_location][:coordinates]).to eq([adviser.longitude, adviser.latitude])
      expect(subject[:range_location][:radius]).to eq('650miles')
    end

    context 'qualifications' do
      let(:qualifications) { [
        Qualification.create(id: 1, order: 1, name: 'First Qualification'),
        Qualification.create(id: 2, order: 2, name: 'Second Qualification')
      ] }
      let(:adviser) { create(:adviser, qualifications: qualifications ) }

      it 'exposes `qualification_ids`' do
        expect(subject[:qualification_ids]).to eq([qualifications.first.id, qualifications.last.id])
      end
    end

    context 'accreditations' do
      let(:accreditations) { [
        Accreditation.create!(id: 1, name: 'First Accreditation', order: 1),
        Accreditation.create!(id: 2, name: 'Second Accreditation', order: 2)
      ] }
      let(:adviser) { create(:adviser, accreditations: accreditations ) }

      it 'exposes `qualification_ids`' do
        expect(subject[:accreditation_ids]).to eq([accreditations.first.id, accreditations.last.id])
      end
    end
  end
end
