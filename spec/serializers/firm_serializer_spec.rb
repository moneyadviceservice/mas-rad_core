RSpec.describe FirmSerializer do
  let(:firm) do
    FactoryBot.create(:firm_with_principal)
  end

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

    it 'exposes `telephone_number`' do
      expect(subject[:telephone_number]).to eql(firm.main_office.telephone_number)
    end

    it 'exposes `website_address`' do
      expect(subject[:website_address]).to eql(firm.website_address)
    end

    it 'exposes `email_address`' do
      expect(subject[:email_address]).to eql(firm.main_office.email_address)
    end

    it 'exposes `free_initial_meeting`' do
      expect(subject[:free_initial_meeting]).to eql(firm.free_initial_meeting)
    end

    it 'exposes `minimum_fixed_fee`' do
      expect(subject[:minimum_fixed_fee]).to eql(firm.minimum_fixed_fee)
    end

    it 'exposes `retirement_income_products`' do
      expect(subject[:retirement_income_products]).to eq(firm.retirement_income_products_flag ? 100 : 0)
    end

    it 'exposes `pension_transfer`' do
      expect(subject[:pension_transfer]).to eq(firm.pension_transfer_flag ? 100 : 0)
    end

    it 'exposes `options_when_paying_for_care`' do
      expect(subject[:options_when_paying_for_care]).to eq(firm.long_term_care_flag ? 100 : 0)
    end

    it 'exposes `equity_release`' do
      expect(subject[:equity_release]).to eq(firm.equity_release_flag ? 100 : 0)
    end

    it 'exposes `inheritance_tax_planning`' do
      expect(subject[:inheritance_tax_planning]).to eq(firm.inheritance_tax_and_estate_planning_flag ? 100 : 0)
    end

    it 'exposes `wills_and_probate`' do
      expect(subject[:wills_and_probate]).to eq(firm.wills_and_probate_flag ? 100 : 0)
    end

    it 'exposes `other_advice_method_ids`' do
      expect(subject[:other_advice_methods]).to eql(firm.other_advice_method_ids)
    end

    it 'exposes `investment_sizes`' do
      expect(subject[:investment_sizes]).to eql(firm.investment_size_ids)
    end

    it 'exposes `in_person_advice_methods`' do
      expect(subject[:in_person_advice_methods]).to eql(firm.in_person_advice_method_ids)
    end

    it 'exposes `adviser_qualification_ids`' do
      expect(subject[:adviser_qualification_ids]).to eql(firm.qualification_ids)
    end

    it 'exposes `adviser_creditation_ids`' do
      expect(subject[:adviser_accreditation_ids]).to eql(firm.accreditation_ids)
    end

    it 'exposes "ethical_investing_flag"' do
      expect(subject[:ethical_investing_flag]).to eql(firm.ethical_investing_flag)
    end

    it 'exposes "sharia_investing_flag"' do
      expect(subject[:sharia_investing_flag]).to eql(firm.sharia_investing_flag)
    end

    it 'exposes "workplace_financial_advice_flag"' do
      expect(subject[:workplace_financial_advice_flag]).to eql(firm.workplace_financial_advice_flag)
    end

    it 'exposes "non_uk_residents_flag"' do
      expect(subject[:non_uk_residents_flag]).to eql(firm.non_uk_residents_flag)
    end

    describe 'advisers' do
      before { create(:adviser, firm: firm, latitude: nil, longitude: nil) }

      it 'only includes geocoded records' do
        expect(subject[:advisers].count).to eq(1)
      end
    end

    describe 'offices' do
      before { create(:office, firm: firm) }

      it 'includes offices (main and additionally created one)' do
        expect(subject[:offices].count).to eq(2)
      end

      context 'when there are offices that have not been geocoded' do
        before { firm.offices.last.update!(latitude: nil, longitude: nil) }

        it 'only includes geocoded records' do
          expect(subject[:offices].count).to eq(1)
        end
      end
    end

    describe 'languages' do
      context 'when languages have been selected' do
        before { firm.languages = ['fra', 'deu'] }

        it 'serializes them' do
          expect(subject[:languages]).to eq(['fra', 'deu'])
        end
      end

      context 'when no languages have been selected' do
        it 'serializes an empty list' do
          expect(subject[:languages]).to eq([])
        end
      end
    end
  end
end
