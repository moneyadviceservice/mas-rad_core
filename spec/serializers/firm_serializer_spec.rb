RSpec.describe FirmSerializer do
  let(:firm) { create(:adviser).firm }

  describe 'the serialized json' do
    subject { described_class.new(firm).as_json }

    it 'exposes `_id`' do
      expect(subject[:_id]).to eql(firm.id)
    end

    it 'exposes `registered_name`' do
      expect(subject[:registered_name]).to eql(firm.registered_name)
    end

    it 'exposes `postcode_searchable`' do
      expect(subject[:postcode_searchable]).to eql(firm.postcode_searchable?)
    end

    it 'exposes the `advisers` association' do
      expect(subject[:advisers]).to be
    end
  end
end
