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

    it 'exposes `pension_transfer`' do
      expect(subject[:pension_transfer]).to eq(firm.pension_transfer_percent)
    end

    it 'exposes `options_when_paying_for_care`' do
      expect(subject[:options_when_paying_for_care]).to eq(firm.long_term_care_percent)
    end

    it 'exposes `equity_release`' do
      expect(subject[:equity_release]).to eq(firm.equity_release_percent)
    end

    it 'exposes `inheritance_tax_planning`' do
      expect(subject[:inheritance_tax_planning]).to eq(firm.inheritance_tax_and_estate_planning_percent)
    end

    it 'exposes `wills_and_probate`' do
      expect(subject[:wills_and_probate]).to eq(firm.wills_and_probate_percent)
    end

    it 'exposes `other_advice_method_ids`' do
      expect(subject[:other_advice_methods]).to eql(firm.other_advice_method_ids)
    end

    it 'exposes `investment_size_ids`' do
      expect(subject[:investment_sizes]).to eql(firm.investment_size_ids)
    end

    it 'exposes `advises_on_investments`' do
      expect(subject[:advises_on_investments]).to be
    end

    context 'when pension transfer percent is more than zero' do
      it 'exposes `investment_transfers` as true' do
        expect(subject[:investment_transfers]).to be
      end
    end

    context 'when pension transfer percent is not present' do
      before { firm.pension_transfer_percent = nil }

      it 'exposes `investment_transfers` as false' do
        expect(subject[:investment_transfers]).to be false
      end
    end

    describe 'advisers' do
      before { create(:adviser, firm: firm, latitude: nil, longitude: nil) }

      it 'only includes geocoded records' do
        expect(subject[:advisers].count).to eq(1)
      end
    end
  end
end
