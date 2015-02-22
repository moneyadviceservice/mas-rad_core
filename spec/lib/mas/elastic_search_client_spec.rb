RSpec.describe ElasticSearchClient do
  describe 'configuration' do
    context 'when unconfigured' do
      it 'defaults the index' do
        expect(described_class.new.index).to eql('rad_test')
      end

      it 'defaults the server' do
        expect(described_class.new.server).to eql('http://localhost:9200')
      end
    end

    context 'when configured' do
      before { @original_url = ENV['BONSAI_URL'] }

      it 'configures server from the BONSAI_URL' do
        ENV['BONSAI_URL'] = 'http://example.com'

        expect(described_class.new.server).to eql(ENV['BONSAI_URL'])
      end

      after { ENV['BONSAI_URL'] = @original_url }
    end
  end

  describe '#store' do
    it 'WIP'
  end
end
