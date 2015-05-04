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
    context 'when successful' do
      it 'returns truthily' do
        VCR.use_cassette(:store_firm_1) do
          expect(described_class.new.store('firms/1', {})).to be_truthy
        end
      end
    end
  end

  describe '#search' do
    context 'when successful' do
      it 'returns an OK status' do
        VCR.use_cassette(:search_firms) do
          expect(described_class.new.search('firms/_search')).to be_ok
        end
      end
    end
  end

  describe '#find' do
    context 'when successful' do
      it 'returns an OK status' do
        VCR.use_cassette(:find_firm) do
          expect(described_class.new.find('firms/257')).to be_ok
        end
      end
    end
  end

  describe '#delete' do
    context 'when successful' do
      it 'returns truthily' do
        VCR.use_cassette(:delete_firm_1) do
          expect(described_class.new.delete('firms/1')).to be_truthy
        end
      end
    end
  end
end
