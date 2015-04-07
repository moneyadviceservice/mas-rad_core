RSpec.describe SearchResult do
  describe 'initialization' do
    it 'is configured with the response' do
      expect(described_class.new(:hi).raw_response).to eq(:hi)
    end
  end

  describe '#firms' do
    context 'when the response is not `ok?`' do
      let(:response) { double(ok?: false) }

      it 'returns []' do
        expect(described_class.new(response).firms).to be_empty
      end
    end

    context 'when the response is `ok?`' do
      let(:response) { double(ok?: true, body: body) }

      context 'with results' do
        let(:json) do
          JSON.parse(
            IO.read(Rails.root.join('..', 'fixtures', 'search_results.json'))
          )
        end
        let(:body) { JSON.dump(json) }

        subject { described_class.new(response) }

        it 'returns 3 deserialized results' do
          expect(subject.firms.length).to eq(3)
        end

        describe 'pagination' do
          it 'has a #current_page' do
            expect(subject.current_page).to eq(1)
          end

          it 'has #total_records' do
            expect(subject.total_records).to eq(3)
          end

          it 'has a #first_record' do
            expect(subject.first_record).to eq(1)
          end

          it 'has a #last_record' do
            expect(subject.last_record).to eq(3)
          end

          it 'has a #page_size' do
            expect(subject.page_size).to eq(MAS::RadCore::PAGE_SIZE)
          end

          it 'has a #limit_value' do
            expect(subject.page_size).to eq(subject.limit_value)
          end

          context 'with 3 records' do
            it '#total_pages is 1' do
              expect(subject.total_pages).to eq(1)
            end
          end

          context 'with 30 records' do
            before { json['hits']['total'] = 30 }

            it '#total_pages is 3' do
              expect(subject.total_pages).to eq(3)
            end
          end

          context 'with 31 records' do
            before { json['hits']['total'] = 31 }

            it '#total_pages is 4' do
              expect(subject.total_pages).to eq(4)
            end
          end
        end
      end
    end
  end
end
