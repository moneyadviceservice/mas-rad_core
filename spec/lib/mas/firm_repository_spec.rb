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
        expect(client).to receive(:search).with(/.*/, {})

        described_class.new(client_class).search(double(as_json: {}))
      end
    end
  end
end
