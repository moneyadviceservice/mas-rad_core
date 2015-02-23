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

  describe '#store' do
    let(:firm) { create(:firm) }
    let(:client) { double }

    before { FakeClient = double(new: client) }

    it 'delegates to the configured client' do
      expect(client).to receive(:store).with(/firms\/\d+/, hash_including(:_id))

      described_class.new(FakeClient).store(firm)
    end
  end
end
