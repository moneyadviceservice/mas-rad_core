RSpec.shared_examples 'friendly named' do
  let(:type) { described_class.model_name.i18n_key }
  let(:method) { create(type, order: 1) }

  before do
    I18n.backend.store_translations :en, type => { ordinal: { '1': 'Phone' } }
  end

  subject { described_class.friendly_name(method.id) }

  it 'returns the shortened equivalent name' do
    expect(subject).to eq('Phone')
  end
end
