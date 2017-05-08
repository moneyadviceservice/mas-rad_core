RSpec.describe OfficeSerializer do
  let(:office) { create(:firm).main_office }

  subject { described_class.new(office).as_json }

  describe 'the serialized json' do
    specify { expect(subject[:_id]).to eq(office.id) }
    specify { expect(subject[:address_line_one]).to eq(office.address_line_one) }
    specify { expect(subject[:address_line_two]).to eq(office.address_line_two) }
    specify { expect(subject[:address_town]).to eq(office.address_town) }
    specify { expect(subject[:address_county]).to eq(office.address_county) }
    specify { expect(subject[:address_postcode]).to eq(office.address_postcode) }
    specify { expect(subject[:email_address]).to eq(office.email_address) }
    specify { expect(subject[:telephone_number]).to eq(office.telephone_number) }
    specify { expect(subject[:disabled_access]).to eq(office.disabled_access) }
    specify { expect(subject[:location][:lat]).to eql(office.latitude) }
    specify { expect(subject[:location][:lon]).to eql(office.longitude) }
    specify { expect(subject[:website]).to eql(office.website) }
  end
end
