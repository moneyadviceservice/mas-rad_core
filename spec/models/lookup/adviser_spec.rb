RSpec.describe Lookup::Adviser do
  describe 'validation' do
    it 'is valid with valid attributes' do
      expect(
        described_class.new(reference_number: 'AAA00001', name: 'Ben Lovell')
      ).to be_valid
    end

    describe 'Reference number rules' do
      it 'must be 8 characters' do
        expect(described_class.new(reference_number: '123A45')).to_not be_valid
      end
    end

    describe 'Name rules' do
      it 'must be provided' do
        expect(described_class.new(reference_number: 'AAA00001')).to_not be_valid
      end
    end
  end
end
