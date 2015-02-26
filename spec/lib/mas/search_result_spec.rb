RSpec.describe SearchResult do
  describe 'initialization' do
    it 'is configured with the response' do
      expect(described_class.new(:hi).raw_response).to eq(:hi)
    end
  end

  describe '#firms' do

    context 'when the response is not `ok?`' do
      let(:response) { double(status: double(ok?: false)) }

      it 'returns []' do
        expect(described_class.new(response).firms).to be_empty
      end
    end

    context 'when the response is `ok?`' do
      context 'with results' do
        it 'is pending'
      end
    end
  end
end
