RSpec.describe Principal do
  let(:principal) { create(:principal) }

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

    describe 'Website address' do
      context 'when provided' do
        it 'must not exceed 100 characters' do
          expect(build(:principal, website_address: "#{'a' * 100}.com")).not_to be_valid
        end
      end
    end
  end

  describe 'dough #field_order' do
    let(:fields) do
      [
        :fca_number,
        :website_address,
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
end
