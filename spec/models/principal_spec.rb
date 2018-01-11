RSpec.describe Principal do
  let(:principal) { create(:principal) }
  let(:trading_name) { create(:firm, parent: principal.firm, fca_number: principal.fca_number) }

  describe '#firm' do
    let(:parent_firm) { Firm.find_by(fca_number: principal.fca_number, parent: nil) }

    it 'fetches the parent firm' do
      expect(principal.firm).to eq(parent_firm)
    end
  end

  describe '#main_firm_with_trading_names' do
    it 'fetches all firms associated with the principal' do
      expect(principal.main_firm_with_trading_names).to contain_exactly(principal.firm, trading_name)
    end
  end

  describe '#lookup_firm' do
    it 'returns my associated lookup firm' do
      expect(principal.lookup_firm).to be
    end
  end

  describe '#subsidiaries?' do
    context 'when my firm has subsidiaries' do
      before { principal.lookup_firm.subsidiaries.create! }

      it 'is truthy' do
        expect(principal.subsidiaries?).to be_truthy
      end
    end

    context 'when my firm has no subsidiaries' do
      it 'is falsey' do
        expect(principal.subsidiaries?).to be_falsey
      end
    end
  end

  describe '#full_name' do
    it 'returns a string containing the first and last name together' do
      expect(principal.full_name).to eq("#{principal.first_name} #{principal.last_name}")
    end
  end

  it 'uses the token for ID purposes' do
    expect(principal.id).to eq(principal.token)
    expect(Principal.find(principal.token)).to eq(principal)
  end

  context 'upon creation' do
    it 'generates an 8 character, 4 byte token' do
      expect(principal.token.length).to eq(8)
    end

    it 'creates the associated Firm' do
      expect(principal.firm.fca_number).to eq(principal.lookup_firm.fca_number)
    end
  end

  describe 'validation' do
    it 'is valid with valid attributes' do
      expect(principal).to be_valid
    end

    it 'must confirm accuracy' do
      expect(build(:principal, confirmed_disclaimer: false)).to_not be_valid
    end

    describe 'FCA number' do
      it 'must be a present' do
        build(:principal).tap do |p|
          p.fca_number = nil
          expect(p).to_not be_valid
        end
      end

      it 'must be a 6 digit number' do
        build(:principal).tap do |p|
          p.fca_number = 12345
          expect(p).to_not be_valid
        end
      end

      it 'must match a `Lookup::Firm`' do
        Lookup::Firm.find_by(fca_number: principal.fca_number).destroy

        expect(principal).to_not be_valid
      end

      it 'must be unique' do
        build(:principal).tap do |p|
          p.fca_number = principal.fca_number
          expect(p).to_not be_valid
        end
      end
    end

    describe 'Email address' do
      it 'must be present' do
        expect(build(:principal, email_address: '')).to_not be_valid
      end

      it 'must be unique' do
        dupe = build(:principal, email_address: principal.email_address)
        expect(dupe).to_not be_valid
      end

      it 'must be a reasonably valid format' do
        %w(zzz abc@abc a@a.).each do |bad|
          principal.email_address = bad
          expect(principal).to_not be_valid
        end
      end

      it 'must not exceed 50 characters' do
        long_email = "a@#{'a' * 50}.com"
        expect(build(:principal, email_address: long_email)).to_not be_valid
      end
    end

    describe 'First name' do
      it 'must be present' do
        expect(build(:principal, first_name: '')).to_not be_valid
      end

      it 'must be at least 2 characters' do
        expect(build(:principal, first_name: 'A')).to_not be_valid
      end

      it 'must not exceed 80 characters' do
        expect(build(:principal, first_name: 'A' * 81)).to_not be_valid
      end
    end

    describe 'Last name' do
      it 'must be present' do
        expect(build(:principal, last_name: '')).to_not be_valid
      end

      it 'must be at least 2 characters' do
        expect(build(:principal, last_name: 'A')).to_not be_valid
      end

      it 'must not exceed 80 characters' do
        expect(build(:principal, last_name: 'A' * 81)).to_not be_valid
      end
    end

    describe 'Job title' do
      it 'must be present' do
        expect(build(:principal, job_title: '')).to_not be_valid
      end

      it 'must be at least 2 characters' do
        expect(build(:principal, job_title: 'A')).to_not be_valid
      end

      it 'must not exceed 80 characters' do
        expect(build(:principal, job_title: 'A' * 81)).to_not be_valid
      end
    end

    describe 'Telephone number' do
      it 'must be present' do
        expect(build(:principal, telephone_number: '')).to_not be_valid
      end

      it 'must not exceed 50 characters' do
        expect(build(:principal, telephone_number: '1' * 51)).to_not be_valid
      end

      it 'must contain only digits and spaces' do
        expect(build(:principal, telephone_number: '1 abcd')).to_not be_valid
      end
    end
  end

  describe 'dough #field_order' do
    let(:fields) do
      [
        :fca_number,
        :first_name,
        :last_name,
        :job_title,
        :email_address,
        :telephone_number,
        :confirmed_disclaimer
      ]
    end

    it 'orders fields per the identification form' do
      expect(principal.field_order).to contain_exactly(*fields)
    end
  end

  describe '#destroy' do
    it 'cascades to the firm' do
      firm = principal.firm
      principal.destroy
      expect(Firm.where(id: firm.id)).to be_empty
    end
  end

  describe '#onboarded?' do
    context 'when no firms are publishable' do
      before do
        FactoryBot.build(:invalid_firm,
                           fca_number: principal.fca_number,
                           parent: principal.firm).save(validate: false)

        expect(principal.main_firm_with_trading_names).to have(2).items
        expect(principal.main_firm_with_trading_names)
          .to all(have_attributes(publishable?: false))
      end

      it 'returns false' do
        expect(principal.onboarded?).to be(false)
      end
    end

    context 'when one firm is publishable' do
      before do
        FactoryBot.create(:publishable_firm,
                           fca_number: principal.fca_number,
                           parent: principal.firm)

        expect(principal.main_firm_with_trading_names).to have(2).items
        expect(principal.firm).not_to be_publishable
        expect(principal.firm.trading_names.first).to be_publishable
      end

      it 'returns true' do
        expect(principal.onboarded?).to be(true)
      end
    end
  end
end
