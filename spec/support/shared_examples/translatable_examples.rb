RSpec.shared_examples 'translatable' do
  let(:factory) { described_class.model_name.singular.to_sym }
  let(:model) { build(factory) }

  describe '#en_name' do
    it 'returns the value for name' do
      expect(model.en_name).to eql(model.name)
    end
  end

  describe '#localized_name' do
    context 'when locale is "cy"' do
      around do |example|
        I18n.with_locale(:cy) { example.run }
      end

      it 'returns the value for cy_name' do
        expect(model.localized_name).to eql(model.cy_name)
      end
    end

    context 'when locale is "en"' do
      around do |example|
        I18n.with_locale(:en) { example.run }
      end

      it 'returns the value for name' do
        expect(model.localized_name).to eql(model.name)
      end
    end
  end
end
