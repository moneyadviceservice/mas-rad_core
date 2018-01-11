# coding: utf-8
RSpec.describe Snapshot do
  let(:england_postcode) { 'EC1N 2TD' }
  let(:scotland_postcode) { 'EH3 9DR' }
  let(:wales_postcode) { 'CF14 4HY' }
  let(:northern_ireland_postcode) { 'BT1 6DP' }

  describe '#save_and_run' do
    it 'runs all queries and sets the count of their result' do
      query_methods = subject.metrics_in_order.map { |metric| "query_#{metric}" }
      query_methods.each_with_index do |query_method, index|
        allow(subject).to receive(query_method).and_return(Array.new(index))
      end

      subject.run_queries_and_save

      subject.metrics_in_order.each_with_index do |metric, index|
        expect(subject.send(metric)).to eq(index)
      end
    end
  end

  describe '#query_firms_with_no_minimum_fee' do
    before do
      FactoryBot.create(:firm, minimum_fixed_fee: 0)
      FactoryBot.create(:firm, minimum_fixed_fee: 0)
      FactoryBot.create(:firm, minimum_fixed_fee: 500)
    end

    it { expect(subject.query_firms_with_no_minimum_fee.count).to eq(2) }
  end

  describe '#query_firms_with_min_fee_between_1_500' do
    before do
      FactoryBot.create(:firm, minimum_fixed_fee: 0)
      FactoryBot.create(:firm, minimum_fixed_fee: 1)
      FactoryBot.create(:firm, minimum_fixed_fee: 500)
      FactoryBot.create(:firm, minimum_fixed_fee: 501)
    end

    it { expect(subject.query_firms_with_min_fee_between_1_500.count).to eq(2) }
  end

  describe '#query_firms_with_min_fee_between_501_1000' do
    before do
      FactoryBot.create(:firm, minimum_fixed_fee: 500)
      FactoryBot.create(:firm, minimum_fixed_fee: 501)
      FactoryBot.create(:firm, minimum_fixed_fee: 750)
      FactoryBot.create(:firm, minimum_fixed_fee: 1000)
      FactoryBot.create(:firm, minimum_fixed_fee: 1001)
    end

    it { expect(subject.query_firms_with_min_fee_between_501_1000.count).to eq(3) }
  end

  describe '#query_firms_any_pot_size' do
    before do
      under_50k_size = FactoryBot.create(:investment_size, name: 'Under £50,000')
      other_size = FactoryBot.create(:investment_size)
      FactoryBot.create(:firm, investment_sizes: [under_50k_size])
      FactoryBot.create(:firm, investment_sizes: [under_50k_size, other_size])
      FactoryBot.create(:firm, investment_sizes: [other_size])
    end

    it { expect(subject.query_firms_any_pot_size.count).to eq(2) }
  end

  describe '#query_firms_any_pot_size_min_fee_less_than_500' do
    before do
      under_50k_size = FactoryBot.create(:investment_size, name: 'Under £50,000')
      other_size = FactoryBot.create(:investment_size)
      FactoryBot.create(:firm, minimum_fixed_fee: 0, investment_sizes: [under_50k_size])
      FactoryBot.create(:firm, minimum_fixed_fee: 499, investment_sizes: [other_size])
      FactoryBot.create(:firm, minimum_fixed_fee: 499, investment_sizes: [under_50k_size])
      FactoryBot.create(:firm, minimum_fixed_fee: 500, investment_sizes: [under_50k_size])
    end

    it { expect(subject.query_firms_any_pot_size_min_fee_less_than_500.count).to eq(2) }
  end

  describe '#query_registered_firms' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm)
      FactoryBot.build(:firm, Firm::REGISTERED_MARKER_FIELD => nil).tap { |f| f.save(validate: false) }
    end

    it { expect(subject.query_registered_firms.count).to eq(2) }
  end

  describe '#query_published_firms' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm, :without_offices)
    end

    it { expect(subject.query_published_firms.count).to eq(1) }
  end

  describe '#query_firms_offering_face_to_face_advice' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm)
      FactoryBot.create(:firm, :with_remote_advice)
    end

    it { expect(subject.query_firms_offering_face_to_face_advice.count).to eq(2) }
  end

  describe '#query_firms_offering_remote_advice' do
    before do
      FactoryBot.create(:firm, :with_remote_advice)
      FactoryBot.create(:firm, :with_remote_advice)
      FactoryBot.create(:firm)
    end

    it { expect(subject.query_firms_offering_remote_advice.count).to eq(2) }
  end

  describe '#query_firms_in_england' do
    let(:firm1) { FactoryBot.create(:firm) }
    let(:firm2) { FactoryBot.create(:firm) }
    let(:firm3) { FactoryBot.create(:firm) }

    before do
      firm1.offices.first.update(address_postcode: england_postcode)
      firm2.offices.first.update(address_postcode: england_postcode)
      firm3.offices.first.update(address_postcode: scotland_postcode)
    end

    it do
      VCR.use_cassette("england_and_scotland_postcode") do
        firms = subject.query_firms_in_england
        expect(firms).to match([firm1, firm2])
        expect(firms).not_to include(firm3)
      end
    end
  end

  describe '#query_firms_in_scotland' do
    let(:firm1) { FactoryBot.create(:firm) }
    let(:firm2) { FactoryBot.create(:firm) }
    let(:firm3) { FactoryBot.create(:firm) }

    before do
      firm1.offices.first.update(address_postcode: scotland_postcode)
      firm2.offices.first.update(address_postcode: scotland_postcode)
      firm3.offices.first.update(address_postcode: england_postcode)
    end

    it do
      VCR.use_cassette("scotland_and_england_postcode") do
        firms = subject.query_firms_in_scotland
        expect(firms).to match([firm1, firm2])
        expect(firms).not_to include(firm3)
      end
    end
  end

  describe '#query_firms_in_wales' do
    let(:firm1) { FactoryBot.create(:firm) }
    let(:firm2) { FactoryBot.create(:firm) }
    let(:firm3) { FactoryBot.create(:firm) }

    before do
      firm1.offices.first.update(address_postcode: wales_postcode)
      firm2.offices.first.update(address_postcode: wales_postcode)
      firm3.offices.first.update(address_postcode: england_postcode)
    end

    it do
      VCR.use_cassette("wales_and_england_postcode") do
        firms = subject.query_firms_in_wales
        expect(firms).to match([firm1, firm2])
        expect(firms).not_to include(firm3)
      end
    end
  end

  describe '#query_firms_in_northern_ireland' do
    let(:firm1) { FactoryBot.create(:firm) }
    let(:firm2) { FactoryBot.create(:firm) }
    let(:firm3) { FactoryBot.create(:firm) }

    before do
      firm1.offices.first.update(address_postcode: northern_ireland_postcode)
      firm2.offices.first.update(address_postcode: northern_ireland_postcode)
      firm3.offices.first.update(address_postcode: england_postcode)
    end

    it do
      VCR.use_cassette("northern_ireland_and_england_postcode") do
        firms = subject.query_firms_in_northern_ireland
        expect(firms).to match([firm1, firm2])
        expect(firms).not_to include(firm3)
      end
    end
  end

  describe '#query_firms_providing_retirement_income_products' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm)
      FactoryBot.create(:firm, retirement_income_products_flag: false)
    end

    it { expect(subject.query_firms_providing_retirement_income_products.count).to eq(2) }
  end

  describe '#query_firms_providing_pension_transfer' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm)
      FactoryBot.create(:firm, pension_transfer_flag: false)
    end

    it { expect(subject.query_firms_providing_pension_transfer.count).to eq(2) }
  end

  describe '#query_firms_providing_long_term_care' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm)
      FactoryBot.create(:firm, long_term_care_flag: false)
    end

    it { expect(subject.query_firms_providing_long_term_care.count).to eq(2) }
  end

  describe '#query_firms_providing_equity_release' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm)
      FactoryBot.create(:firm, equity_release_flag: false)
    end

    it { expect(subject.query_firms_providing_equity_release.count).to eq(2) }
  end

  describe '#query_firms_providing_inheritance_tax_and_estate_planning' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm)
      FactoryBot.create(:firm, inheritance_tax_and_estate_planning_flag: false)
    end

    it { expect(subject.query_firms_providing_inheritance_tax_and_estate_planning.count).to eq(2) }
  end

  describe '#query_firms_providing_wills_and_probate' do
    before do
      FactoryBot.create(:firm)
      FactoryBot.create(:firm)
      FactoryBot.create(:firm, wills_and_probate_flag: false)
    end

    it { expect(subject.query_firms_providing_wills_and_probate.count).to eq(2) }
  end

  describe '#query_firms_providing_ethical_investing' do
    before do
      FactoryBot.create(:firm, ethical_investing_flag: true)
      FactoryBot.create(:firm, ethical_investing_flag: true)
      FactoryBot.create(:firm, ethical_investing_flag: false)
    end

    it { expect(subject.query_firms_providing_ethical_investing.count).to eq(2) }
  end

  describe '#query_firms_providing_sharia_investing' do
    before do
      FactoryBot.create(:firm, sharia_investing_flag: true)
      FactoryBot.create(:firm, sharia_investing_flag: true)
      FactoryBot.create(:firm, sharia_investing_flag: false)
    end

    it { expect(subject.query_firms_providing_sharia_investing.count).to eq(2) }
  end

  describe '#query_firms_providing_workplace_financial_advice' do
    before do
      FactoryBot.create(:firm, workplace_financial_advice_flag: true)
      FactoryBot.create(:firm, workplace_financial_advice_flag: false)
      FactoryBot.create(:firm, workplace_financial_advice_flag: true)
    end

    it { expect(subject.query_firms_providing_workplace_financial_advice.count).to eq(2) }
  end

  describe '#query_firms_providing_non_uk_residents' do
    before do
      FactoryBot.create(:firm, non_uk_residents_flag: false)
      FactoryBot.create(:firm, non_uk_residents_flag: true)
      FactoryBot.create(:firm, non_uk_residents_flag: true)
    end

    it { expect(subject.query_firms_providing_non_uk_residents.count).to eq(2) }
  end

  describe '#query_firms_offering_languages_other_than_english' do
    before do
      FactoryBot.create(:firm, languages: [])
      FactoryBot.create(:firm, languages: ['fra'])
      FactoryBot.create(:firm, languages: ['fra'])
    end

    it { expect(subject.query_firms_offering_languages_other_than_english.count).to eq(2) }
  end

  describe '#query_offices_with_disabled_access' do
    before do
      firm1 = FactoryBot.create(:firm, offices_count: 1)
      firm1.offices.first.update(disabled_access: false)

      firm2 = FactoryBot.create(:firm, offices_count: 1)
      firm2.offices.first.update(disabled_access: true)

      firm3 = FactoryBot.create(:firm, :without_advisers, offices_count: 1)
      firm3.offices.first.update(disabled_access: true)
    end

    it { expect(subject.query_offices_with_disabled_access.count).to eq(1) }
  end

  describe '#query_registered_advisers' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser)
    end

    it { expect(subject.query_registered_advisers.count).to eq(2) }
  end

  describe '#query_advisers_in_england' do
    let!(:adviser1) { FactoryBot.create(:adviser, postcode: england_postcode) }
    let!(:adviser2) { FactoryBot.create(:adviser, postcode: england_postcode) }
    let!(:adviser3) { FactoryBot.create(:adviser, postcode: scotland_postcode) }

    it do
      VCR.use_cassette("england_and_scotland_postcode") do
        advisers = subject.query_advisers_in_england
        expect(advisers).to match([adviser1, adviser2])
        expect(advisers).not_to include(adviser3)
      end
    end
  end

  describe '#query_advisers_in_scotland' do
    let!(:adviser1) { FactoryBot.create(:adviser, postcode: scotland_postcode) }
    let!(:adviser2) { FactoryBot.create(:adviser, postcode: scotland_postcode) }
    let!(:adviser3) { FactoryBot.create(:adviser, postcode: england_postcode) }

    it do
      VCR.use_cassette("scotland_and_england_postcode") do
        advisers = subject.query_advisers_in_scotland
        expect(advisers).to match([adviser1, adviser2])
        expect(advisers).not_to include(adviser3)
      end
    end
  end

  describe '#query_advisers_in_wales' do
    let!(:adviser1) { FactoryBot.create(:adviser, postcode: wales_postcode) }
    let!(:adviser2) { FactoryBot.create(:adviser, postcode: wales_postcode) }
    let!(:adviser3) { FactoryBot.create(:adviser, postcode: england_postcode) }

    it do
      VCR.use_cassette("wales_and_england_postcode") do
        advisers = subject.query_advisers_in_wales
        expect(advisers).to match([adviser1, adviser2])
        expect(advisers).not_to include(adviser3)
      end
    end
  end

  describe '#query_advisers_in_northern_ireland' do
    let!(:adviser1) { FactoryBot.create(:adviser, postcode: northern_ireland_postcode) }
    let!(:adviser2) { FactoryBot.create(:adviser, postcode: northern_ireland_postcode) }
    let!(:adviser3) { FactoryBot.create(:adviser, postcode: england_postcode) }

    it do
      VCR.use_cassette("northern_ireland_and_england_postcode") do
        advisers = subject.query_advisers_in_northern_ireland
        expect(advisers).to match([adviser1, adviser2])
        expect(advisers).not_to include(adviser3)
      end
    end
  end

  describe '#query_advisers_who_travel_5_miles' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['5 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['5 miles'])
    end

    it { expect(subject.query_advisers_who_travel_5_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_10_miles' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['10 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['10 miles'])
    end

    it { expect(subject.query_advisers_who_travel_10_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_25_miles' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['25 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['25 miles'])
    end

    it { expect(subject.query_advisers_who_travel_25_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_50_miles' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['50 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['50 miles'])
    end

    it { expect(subject.query_advisers_who_travel_50_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_100_miles' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['100 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['100 miles'])
    end

    it { expect(subject.query_advisers_who_travel_100_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_150_miles' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['150 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['150 miles'])
    end

    it { expect(subject.query_advisers_who_travel_150_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_200_miles' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['200 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['200 miles'])
    end

    it { expect(subject.query_advisers_who_travel_200_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_250_miles' do
    before do
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['250 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['250 miles'])
    end

    it { expect(subject.query_advisers_who_travel_250_miles.count).to eq(2) }
  end

  describe '#query_advisers_who_travel_uk_wide' do
    before do
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['5 miles'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['UK wide'])
      FactoryBot.create(:adviser, travel_distance: TravelDistance.all['UK wide'])
    end

    it { expect(subject.query_advisers_who_travel_uk_wide.count).to eq(2) }
  end

  describe '#query_advisers_accredited_in_solla' do
    before do
      accreditation = FactoryBot.create(:accreditation, name: 'SOLLA')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, accreditations: [accreditation])
      FactoryBot.create(:adviser, accreditations: [accreditation])
    end

    it { expect(subject.query_advisers_accredited_in_solla.count).to eq(2) }
  end

  describe '#query_advisers_accredited_in_later_life_academy' do
    before do
      accreditation = FactoryBot.create(:accreditation, name: 'Later Life Academy')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, accreditations: [accreditation])
      FactoryBot.create(:adviser, accreditations: [accreditation])
    end

    it { expect(subject.query_advisers_accredited_in_later_life_academy.count).to eq(2) }
  end

  describe '#query_advisers_accredited_in_iso22222' do
    before do
      accreditation = FactoryBot.create(:accreditation, name: 'ISO 22222')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, accreditations: [accreditation])
      FactoryBot.create(:adviser, accreditations: [accreditation])
    end

    it { expect(subject.query_advisers_accredited_in_iso22222.count).to eq(2) }
  end

  describe '#query_advisers_accredited_in_bs8577' do
    before do
      accreditation = FactoryBot.create(:accreditation, name: 'British Standard in Financial Planning BS8577')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, accreditations: [accreditation])
      FactoryBot.create(:adviser, accreditations: [accreditation])
    end

    it { expect(subject.query_advisers_accredited_in_bs8577.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_level_4' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Level 4 (DipPFS, DipFA® or equivalent)')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_level_4.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_level_6' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Level 6 (APFS, Adv DipFA®)')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_level_6.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_chartered_financial_planner' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Chartered Financial Planner')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_chartered_financial_planner.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_certified_financial_planner' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Certified Financial Planner')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_certified_financial_planner.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_pension_transfer' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Pension transfer qualifications - holder of G60, AF3, AwPETR®, or equivalent')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_pension_transfer.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_equity_release' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Equity release qualifications i.e. holder of Certificate in Equity Release or equivalent')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_equity_release.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_long_term_care_planning' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Long term care planning qualifications i.e. holder of CF8, CeLTCI®. or equivalent')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_long_term_care_planning.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_tep' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Holder of Trust and Estate Practitioner qualification (TEP) i.e. full member of STEP')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_tep.count).to eq(2) }
  end

  describe '#query_advisers_with_qualification_in_fcii' do
    before do
      qualification = FactoryBot.create(:qualification, name: 'Fellow of the Chartered Insurance Institute (FCII)')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, qualifications: [qualification])
      FactoryBot.create(:adviser, qualifications: [qualification])
    end

    it { expect(subject.query_advisers_with_qualification_in_fcii.count).to eq(2) }
  end

  describe '#query_advisers_part_of_personal_finance_society' do
    before do
      professional_body = FactoryBot.create(:professional_body, name: 'Personal Finance Society / Chartered Insurance Institute')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_personal_finance_society.count).to eq(2) }
  end

  describe '#query_advisers_part_of_institute_financial_planning' do
    before do
      professional_body = FactoryBot.create(:professional_body, name: 'Institute of Financial Planning')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_institute_financial_planning.count).to eq(2) }
  end

  describe '#query_advisers_part_of_institute_financial_services' do
    before do
      professional_body = FactoryBot.create(:professional_body, name: 'Institute of Financial Services')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_institute_financial_services.count).to eq(2) }
  end

  describe '#query_advisers_part_of_ci_bankers_scotland' do
    before do
      professional_body = FactoryBot.create(:professional_body, name: 'The Chartered Institute of Bankers in Scotland')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_ci_bankers_scotland.count).to eq(2) }
  end

  describe '#query_advisers_part_of_ci_securities_and_investments' do
    before do
      professional_body = FactoryBot.create(:professional_body, name: 'The Chartered Institute for Securities and Investments')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_ci_securities_and_investments.count).to eq(2) }
  end

  describe '#query_advisers_part_of_cfa_institute' do
    before do
      professional_body = FactoryBot.create(:professional_body, name: 'CFA Institute')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_cfa_institute.count).to eq(2) }
  end

  describe '#query_advisers_part_of_chartered_accountants' do
    before do
      professional_body = FactoryBot.create(:professional_body, name: 'Institute of Chartered Accountants for England and Wales')
      FactoryBot.create(:adviser)
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
      FactoryBot.create(:adviser, professional_bodies: [professional_body])
    end

    it { expect(subject.query_advisers_part_of_chartered_accountants.count).to eq(2) }
  end

  describe '#metrics_in_order' do
    it 'has the configured order' do
      expect(subject.metrics_in_order).to eq([
        :firms_with_no_minimum_fee,
        :firms_with_min_fee_between_1_500,
        :firms_with_min_fee_between_501_1000,
        :firms_any_pot_size,
        :firms_any_pot_size_min_fee_less_than_500,
        :registered_firms,
        :published_firms,
        :firms_offering_face_to_face_advice,
        :firms_offering_remote_advice,
        :firms_in_england,
        :firms_in_scotland,
        :firms_in_wales,
        :firms_in_northern_ireland,
        :firms_providing_retirement_income_products,
        :firms_providing_pension_transfer,
        :firms_providing_long_term_care,
        :firms_providing_equity_release,
        :firms_providing_inheritance_tax_and_estate_planning,
        :firms_providing_wills_and_probate,
        :firms_providing_ethical_investing,
        :firms_providing_sharia_investing,
        :firms_providing_workplace_financial_advice,
        :firms_providing_non_uk_residents,
        :firms_offering_languages_other_than_english,
        :offices_with_disabled_access,
        :registered_advisers,
        :advisers_in_england,
        :advisers_in_scotland,
        :advisers_in_wales,
        :advisers_in_northern_ireland,
        :advisers_who_travel_5_miles,
        :advisers_who_travel_10_miles,
        :advisers_who_travel_25_miles,
        :advisers_who_travel_50_miles,
        :advisers_who_travel_100_miles,
        :advisers_who_travel_150_miles,
        :advisers_who_travel_200_miles,
        :advisers_who_travel_250_miles,
        :advisers_who_travel_uk_wide,
        :advisers_accredited_in_solla,
        :advisers_accredited_in_later_life_academy,
        :advisers_accredited_in_iso22222,
        :advisers_accredited_in_bs8577,
        :advisers_with_qualification_in_level_4,
        :advisers_with_qualification_in_level_6,
        :advisers_with_qualification_in_chartered_financial_planner,
        :advisers_with_qualification_in_certified_financial_planner,
        :advisers_with_qualification_in_pension_transfer,
        :advisers_with_qualification_in_equity_release,
        :advisers_with_qualification_in_long_term_care_planning,
        :advisers_with_qualification_in_tep,
        :advisers_with_qualification_in_fcii,
        :advisers_part_of_personal_finance_society,
        :advisers_part_of_institute_financial_planning,
        :advisers_part_of_institute_financial_services,
        :advisers_part_of_ci_bankers_scotland,
        :advisers_part_of_ci_securities_and_investments,
        :advisers_part_of_cfa_institute, :advisers_part_of_chartered_accountants
      ])
    end
  end
end
