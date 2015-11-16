RSpec.shared_examples 'geocodable' do
  describe '#latitude=' do
    let(:latitude) { Faker::Address.latitude }

    before { subject.latitude = latitude }

    it 'casts the value to a float rounded to six decimal places' do
      expect(subject.latitude).to eql(latitude.to_f.round(6))
    end

    context 'when the value is nil' do
      let(:latitude) { nil }

      it 'does not cast the value' do
        expect(subject.latitude).to be_nil
      end
    end
  end

  describe '#longitude=' do
    let(:longitude) { Faker::Address.longitude }

    before { subject.longitude = longitude }

    it 'casts the value to a float rounded to six decimal places' do
      expect(subject.longitude).to eql(longitude.to_f.round(6))
    end

    context 'when the value is nil' do
      let(:longitude) { nil }

      it 'does not cast the value' do
        expect(subject.longitude).to be_nil
      end
    end
  end

  describe '#geocoded?' do
    context 'when the subject has lat/long' do
      before do
        subject.latitude, subject.longitude = [1.0, 1.0]
      end

      it 'is classed as geocoded' do
        expect(subject.geocoded?).to be(true)
      end
    end

    context 'when the subject does not have lat/long' do
      before do
        subject.latitude, subject.longitude = [nil, nil]
      end

      it 'is not classed as geocoded' do
        expect(subject.geocoded?).to be(false)
      end
    end
  end
end
