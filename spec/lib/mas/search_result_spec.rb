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
      let(:response) { double(status: double(ok?: true), body: body) }

      context 'with results' do
        let(:json) { IO.read(Rails.root.join('..', 'fixtures', 'search_results.json')) }
        let(:body) { double(to_s: json) }

        it 'returns 3 deserialized results' do
          expect(described_class.new(response).firms.length).to eq(3)
        end
      end
    end
  end
end
