RSpec.describe FirmRepository do
  describe 'initialization' do
    subject { described_class.new }

    it 'defaults `client`' do
      expect(subject.client).to be_a(ElasticSearchClient)
    end

    it 'defaults `serializer`' do
      expect(subject.serializer).to eql(FirmSerializer)
    end
  end

  describe '#from_for' do
    subject { described_class.new }

    it 'returns 0 for page 1' do
      expect(subject.from_for(1)).to eq(0)
    end

    it 'returns 10 for page 2' do
      expect(subject.from_for(2)).to eq(10)
    end
  end

  describe 'searching and retrieving' do
    let(:client) { double }
    let(:client_class) { double(new: client) }

    describe '#store' do
      let(:firm) { create(:firm) }

      it 'delegates to the configured client' do
        expect(client).to receive(:store).with(/firms\/\d+/, hash_including(:_id))

        described_class.new(client_class).store(firm)
      end
    end

    describe '#search' do
      it 'delegates to the configured client' do
        expect(client).to receive(:search).with('firms/_search?from=90', {})

        described_class.new(client_class).search({}, page: 10)
      end

      it 'returns the `SearchResult`' do
        allow(client).to receive(:search)

        expect(described_class.new(client_class).search({})).to be_a(SearchResult)
      end
    end
  end
end
