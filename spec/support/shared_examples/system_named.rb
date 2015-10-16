RSpec.shared_examples 'system named' do
  let(:type) { described_class.model_name.i18n_key }
  let(:method) { create(type, order: 1) }

  before do
    fail unless described_class::SYSTEM_NAMES
    stub_const("#{described_class.model_name}::SYSTEM_NAMES", { 1 => :phone })
  end

  subject { described_class.system_name(method.id) }

  it 'returns the corresponding system name' do
    expect(subject).to eq(:phone)
  end
end
