RSpec.shared_examples 'reference data' do
  let(:factory) { described_class.model_name.singular.to_sym }
  subject(:model) { build(factory) }

  it 'is valid with valid attributes' do
    expect(model).to be_valid
  end

  context 'when name is not present' do
    before { model.name = nil }

    it { is_expected.to_not be_valid }
  end
end
