RSpec.describe Snapshot do
  describe '#query_firms_with_no_minimum_fee' do
    before do
      FactoryGirl.create(:firm, minimum_fixed_fee: 0)
      FactoryGirl.create(:firm, minimum_fixed_fee: 0)
      FactoryGirl.create(:firm, minimum_fixed_fee: 500)
    end

    it { expect(subject.query_firms_with_no_minimum_fee.count).to eq(2) }
  end

  describe '#query_firms_with_min_fee_between_1_500' do
    before do
      FactoryGirl.create(:firm, minimum_fixed_fee: 0)
      FactoryGirl.create(:firm, minimum_fixed_fee: 1)
      FactoryGirl.create(:firm, minimum_fixed_fee: 500)
      FactoryGirl.create(:firm, minimum_fixed_fee: 501)
    end

    it { expect(subject.query_firms_with_min_fee_between_1_500.count).to eq(2) }
  end

  describe '#query_firms_with_min_fee_between_501_1000' do
    before do
      FactoryGirl.create(:firm, minimum_fixed_fee: 500)
      FactoryGirl.create(:firm, minimum_fixed_fee: 501)
      FactoryGirl.create(:firm, minimum_fixed_fee: 750)
      FactoryGirl.create(:firm, minimum_fixed_fee: 1000)
      FactoryGirl.create(:firm, minimum_fixed_fee: 1001)
    end

    it { expect(subject.query_firms_with_min_fee_between_501_1000.count).to eq(3) }
  end

  describe '#query_firms_any_pot_size' do
    before do
      under_50k_size = FactoryGirl.create(:investment_size, name: 'Under £50,000')
      other_size = FactoryGirl.create(:investment_size)
      FactoryGirl.create(:firm, investment_sizes: [under_50k_size])
      FactoryGirl.create(:firm, investment_sizes: [under_50k_size, other_size])
      FactoryGirl.create(:firm, investment_sizes: [other_size])
    end

    it { expect(subject.query_firms_any_pot_size.count).to eq(2) }
  end

  describe '#query_firms_any_pot_size_min_fee_less_than_500' do
    before do
      under_50k_size = FactoryGirl.create(:investment_size, name: 'Under £50,000')
      other_size = FactoryGirl.create(:investment_size)
      FactoryGirl.create(:firm, minimum_fixed_fee: 0, investment_sizes: [under_50k_size])
      FactoryGirl.create(:firm, minimum_fixed_fee: 499, investment_sizes: [other_size])
      FactoryGirl.create(:firm, minimum_fixed_fee: 499, investment_sizes: [under_50k_size])
      FactoryGirl.create(:firm, minimum_fixed_fee: 500, investment_sizes: [under_50k_size])
    end

    it { expect(subject.query_firms_any_pot_size_min_fee_less_than_500.count).to eq(2) }
  end

  describe '#query_registered_firms' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm)
      FactoryGirl.build(:firm, Firm::REGISTERED_MARKER_FIELD => nil).tap { |f| f.save(validate: false) }
    end

    it { expect(subject.query_registered_firms.count).to eq(2) }
  end

  describe '#query_published_firms' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm, :without_offices)
    end

    it { expect(subject.query_published_firms.count).to eq(1) }
  end

  describe '#query_firms_offering_face_to_face_advice' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm, :with_remote_advice)
    end

    it { expect(subject.query_firms_offering_face_to_face_advice.count).to eq(2) }
  end

  describe '#query_firms_offering_remote_advice' do
    before do
      FactoryGirl.create(:firm, :with_remote_advice)
      FactoryGirl.create(:firm, :with_remote_advice)
      FactoryGirl.create(:firm)
    end

    it { expect(subject.query_firms_offering_remote_advice.count).to eq(2) }
  end

  describe '#query_firms_in_england' do
    before do
      england_postcode = 'EC1N 2TD'
      scotland_postcode = 'EH3 9DR'

      FactoryGirl.create(:firm).offices.first.update(address_postcode: england_postcode)
      FactoryGirl.create(:firm).offices.first.update(address_postcode: england_postcode)
      FactoryGirl.create(:firm).offices.first.update(address_postcode: scotland_postcode)
    end

    it do
      VCR.use_cassette("england_and_scotland_postcode") do
        expect(subject.query_firms_in_england.count).to eq(2)
      end
    end
  end

  describe '#query_firms_in_scotland' do
    before do
      england_postcode = 'EC1N 2TD'
      scotland_postcode = 'EH3 9DR'

      FactoryGirl.create(:firm).offices.first.update(address_postcode: scotland_postcode)
      FactoryGirl.create(:firm).offices.first.update(address_postcode: scotland_postcode)
      FactoryGirl.create(:firm).offices.first.update(address_postcode: england_postcode)
    end

    it do
      VCR.use_cassette("scotland_and_england_postcode") do
        expect(subject.query_firms_in_scotland.count).to eq(2)
      end
    end
  end

  describe '#query_firms_in_wales' do
    before do
      england_postcode = 'EC1N 2TD'
      wales_postcode = 'CF14 4HY'

      FactoryGirl.create(:firm).offices.first.update(address_postcode: wales_postcode)
      FactoryGirl.create(:firm).offices.first.update(address_postcode: wales_postcode)
      FactoryGirl.create(:firm).offices.first.update(address_postcode: england_postcode)
    end

    it do
      VCR.use_cassette("wales_and_england_postcode") do
        expect(subject.query_firms_in_wales.count).to eq(2)
      end
    end
  end

  describe '#query_firms_in_northern_ireland' do
    before do
      england_postcode = 'EC1N 2TD'
      northern_ireland_postcode = 'BT1 6DP'

      FactoryGirl.create(:firm).offices.first.update(address_postcode: northern_ireland_postcode)
      FactoryGirl.create(:firm).offices.first.update(address_postcode: northern_ireland_postcode)
      FactoryGirl.create(:firm).offices.first.update(address_postcode: england_postcode)
    end

    it do
      VCR.use_cassette("northern_ireland_and_england_postcode") do
        expect(subject.query_firms_in_northern_ireland.count).to eq(2)
      end
    end
  end

  describe '#query_firms_providing_retirement_income_products' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm, retirement_income_products_flag: false)
    end

    it { expect(subject.query_firms_providing_retirement_income_products.count).to eq(2) }
  end

  describe '#query_firms_providing_pension_transfer' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm, pension_transfer_flag: false)
    end

    it { expect(subject.query_firms_providing_pension_transfer.count).to eq(2) }
  end

  describe '#query_firms_providing_long_term_care' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm, long_term_care_flag: false)
    end

    it { expect(subject.query_firms_providing_long_term_care.count).to eq(2) }
  end

  describe '#query_firms_providing_equity_release' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm, equity_release_flag: false)
    end

    it { expect(subject.query_firms_providing_equity_release.count).to eq(2) }
  end

  describe '#query_firms_providing_inheritance_tax_and_estate_planning' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm, inheritance_tax_and_estate_planning_flag: false)
    end

    it { expect(subject.query_firms_providing_inheritance_tax_and_estate_planning.count).to eq(2) }
  end

  describe '#query_firms_providing_wills_and_probate' do
    before do
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm)
      FactoryGirl.create(:firm, wills_and_probate_flag: false)
    end

    it { expect(subject.query_firms_providing_wills_and_probate.count).to eq(2) }
  end

  describe '#query_firms_providing_ethical_investing' do
    before do
      FactoryGirl.create(:firm, ethical_investing_flag: true)
      FactoryGirl.create(:firm, ethical_investing_flag: true)
      FactoryGirl.create(:firm, ethical_investing_flag: false)
    end

    it { expect(subject.query_firms_providing_ethical_investing.count).to eq(2) }
  end

  describe '#query_firms_providing_sharia_investing' do
    before do
      FactoryGirl.create(:firm, sharia_investing_flag: true)
      FactoryGirl.create(:firm, sharia_investing_flag: true)
      FactoryGirl.create(:firm, sharia_investing_flag: false)
    end

    it { expect(subject.query_firms_providing_sharia_investing.count).to eq(2) }
  end

  describe '#query_firms_offering_languages_other_than_english' do
    before do
      FactoryGirl.create(:firm, languages: [])
      FactoryGirl.create(:firm, languages: ['fra'])
      FactoryGirl.create(:firm, languages: ['fra'])
    end

    it { expect(subject.query_firms_offering_languages_other_than_english.count).to eq(2) }
  end

  describe '#query_offices_with_disabled_access' do
    before do
      firm1 = FactoryGirl.create(:firm, offices_count: 1)
      firm1.offices.first.update(disabled_access: false)

      firm2 = FactoryGirl.create(:firm, offices_count: 1)
      firm2.offices.first.update(disabled_access: true)

      firm3 = FactoryGirl.create(:firm, :without_advisers, offices_count: 1)
      firm3.offices.first.update(disabled_access: true)
    end

    it { expect(subject.query_offices_with_disabled_access.count).to eq(1) }
  end

  describe '#query_registered_advisers' do
    before do
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser)
    end

    it { expect(subject.query_registered_advisers.count).to eq(2) }
  end

  describe '#query_advisers_in_england' do
    before do
      england_postcode = 'EC1N 2TD'
      scotland_postcode = 'EH3 9DR'

      FactoryGirl.create(:adviser, postcode: england_postcode)
      FactoryGirl.create(:adviser, postcode: england_postcode)
      FactoryGirl.create(:adviser, postcode: scotland_postcode)
    end

    it do
      VCR.use_cassette("england_and_scotland_postcode") do
        expect(subject.query_advisers_in_england.count).to eq(2)
      end
    end
  end

  describe '#query_advisers_in_scotland' do
    before do
      england_postcode = 'EC1N 2TD'
      scotland_postcode = 'EH3 9DR'

      FactoryGirl.create(:adviser, postcode: scotland_postcode)
      FactoryGirl.create(:adviser, postcode: scotland_postcode)
      FactoryGirl.create(:adviser, postcode: england_postcode)
    end

    it do
      VCR.use_cassette("scotland_and_england_postcode") do
        expect(subject.query_advisers_in_scotland.count).to eq(2)
      end
    end
  end

  describe '#query_advisers_in_wales' do
    before do
      england_postcode = 'EC1N 2TD'
      wales_postcode = 'CF14 4HY'

      FactoryGirl.create(:adviser, postcode: wales_postcode)
      FactoryGirl.create(:adviser, postcode: wales_postcode)
      FactoryGirl.create(:adviser, postcode: england_postcode)
    end

    it do
      VCR.use_cassette("wales_and_england_postcode") do
        expect(subject.query_advisers_in_wales.count).to eq(2)
      end
    end
  end

  describe '#query_advisers_in_northern_ireland' do
    before do
      england_postcode = 'EC1N 2TD'
      northern_ireland_postcode = 'BT1 6DP'

      FactoryGirl.create(:adviser, postcode: northern_ireland_postcode)
      FactoryGirl.create(:adviser, postcode: northern_ireland_postcode)
      FactoryGirl.create(:adviser, postcode: england_postcode)
    end

    it do
      VCR.use_cassette("northern_ireland_and_england_postcode") do
        expect(subject.query_advisers_in_northern_ireland.count).to eq(2)
      end
    end
  end

  describe '#query_advisers_who_travel_5_miles' do
    before do
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['5 miles'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['5 miles'])
    end

    it { expect(subject.query_advisers_who_travel_5_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_10_miles' do
    before do
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['10 miles'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['10 miles'])
    end

    it { expect(subject.query_advisers_who_travel_10_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_25_miles' do
    before do
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['25 miles'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['25 miles'])
    end

    it { expect(subject.query_advisers_who_travel_25_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_50_miles' do
    before do
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['50 miles'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['50 miles'])
    end

    it { expect(subject.query_advisers_who_travel_50_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_100_miles' do
    before do
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['100 miles'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['100 miles'])
    end

    it { expect(subject.query_advisers_who_travel_100_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_150_miles' do
    before do
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['150 miles'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['150 miles'])
    end

    it { expect(subject.query_advisers_who_travel_150_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_250_miles' do
    before do
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['250 miles'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['250 miles'])
    end

    it { expect(subject.query_advisers_who_travel_250_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_uk_wide' do
    before do
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['5 miles'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['UK wide'])
      FactoryGirl.create(:adviser, travel_distance: TravelDistance.all['UK wide'])
    end

    it { expect(subject.query_advisers_who_travel_uk_wide.count).to eq(2) }
  end

  describe '#query_advisers_accredited_in_solla' do
    before do
      accreditation = FactoryGirl.create(:accreditation, name: 'SOLLA')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, accreditations: [accreditation])
      FactoryGirl.create(:adviser, accreditations: [accreditation])
    end

    it { expect(subject.query_advisers_accredited_in_solla.count).to eq(2) }
  end

  describe '#query_advisers_accredited_in_later_life_academy' do
    before do
      accreditation = FactoryGirl.create(:accreditation, name: 'Later Life Academy')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, accreditations: [accreditation])
      FactoryGirl.create(:adviser, accreditations: [accreditation])
    end

    it { expect(subject.query_advisers_accredited_in_later_life_academy.count).to eq(2) }
  end

  describe '#query_advisers_accredited_in_iso22222' do
    before do
      accreditation = FactoryGirl.create(:accreditation, name: 'ISO 22222')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, accreditations: [accreditation])
      FactoryGirl.create(:adviser, accreditations: [accreditation])
    end

    it { expect(subject.query_advisers_accredited_in_iso22222.count).to eq(2) }
  end

  describe '#query_advisers_accredited_in_bs8577' do
    before do
      accreditation = FactoryGirl.create(:accreditation, name: 'British Standard in Financial Planning BS8577')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, accreditations: [accreditation])
      FactoryGirl.create(:adviser, accreditations: [accreditation])
    end

    it { expect(subject.query_advisers_accredited_in_bs8577.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_level_4' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Level 4 (DipPFS, DipFA® or equivalent)')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_level_4.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_level_6' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Level 6 (APFS, Adv DipFA®)')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_level_6.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_chartered_financial_planner' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Chartered Financial Planner')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_chartered_financial_planner.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_certified_financial_planner' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Certified Financial Planner')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_certified_financial_planner.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_pension_transfer' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Pension transfer qualifications - holder of G60, AF3, AwPETR®, or equivalent')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_pension_transfer.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_equity_release' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Equity release qualifications i.e. holder of Certificate in Equity Release or equivalent')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_equity_release.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_long_term_care_planning' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Long term care planning qualifications i.e. holder of CF8, CeLTCI®. or equivalent')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_long_term_care_planning.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_tep' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Holder of Trust and Estate Practitioner qualification (TEP) i.e. full member of STEP')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_tep.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_fcii' do
    before do
      qualification = FactoryGirl.create(:qualification, name: 'Fellow of the Chartered Insurance Institute (FCII)')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, qualifications: [qualification])
      FactoryGirl.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_fcii.count).to eq(2) }
  end

  describe '#query_advisers_part_of_personal_finance_society' do
    before do
      professional_body = FactoryGirl.create(:professional_body, name: 'Personal Finance Society / Chartered Insurance Institute')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_personal_finance_society.count).to eq(2) }
  end

  describe '#query_advisers_part_of_institute_financial_planning' do
    before do
      professional_body = FactoryGirl.create(:professional_body, name: 'Institute of Financial Planning')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_institute_financial_planning.count).to eq(2) }
  end

  describe '#query_advisers_part_of_institute_financial_services' do
    before do
      professional_body = FactoryGirl.create(:professional_body, name: 'Institute of Financial Services')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_institute_financial_services.count).to eq(2) }
  end

  describe '#query_advisers_part_of_ci_bankers_scotland' do
    before do
      professional_body = FactoryGirl.create(:professional_body, name: 'The Chartered Institute of Bankers in Scotland')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_ci_bankers_scotland.count).to eq(2) }
  end

  describe '#query_advisers_part_of_ci_securities_and_investments' do
    before do
      professional_body = FactoryGirl.create(:professional_body, name: 'The Chartered Institute for Securities and Investments')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_ci_securities_and_investments.count).to eq(2) }
  end

  describe '#query_advisers_part_of_cfa_institute' do
    before do
      professional_body = FactoryGirl.create(:professional_body, name: 'CFA Institute')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_cfa_institute.count).to eq(2) }
  end

  describe '#query_advisers_part_of_chartered_accountants' do
    before do
      professional_body = FactoryGirl.create(:professional_body, name: 'Institute of Chartered Accountants for England and Wales')
      FactoryGirl.create(:adviser)
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
      FactoryGirl.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_chartered_accountants.count).to eq(2) }
  end
end
