require 'net/http'

class Snapshot < ActiveRecord::Base
  def query_firms_with_no_minimum_fee
    published_firms.select { |f| [0, nil].include?(f.minimum_fixed_fee) }
  end

  def query_firms_with_min_fee_between_1_500
    published_firms.select { |f| (1..500).include?(f.minimum_fixed_fee) }
  end

  def query_firms_with_min_fee_between_501_1000
    published_firms.select { |f| (501..1000).include?(f.minimum_fixed_fee) }
  end

  def query_firms_any_pot_size
    under_50k_size = InvestmentSize.find_by(name: 'Under £50,000')
    published_firms.select { |f| f.investment_sizes.exists?(under_50k_size.id) }
  end

  def query_firms_any_pot_size_min_fee_less_than_500
    query_firms_any_pot_size.select do |f|
      f.minimum_fixed_fee < 500
    end
  end

  def query_registered_firms
    Firm.registered
  end

  def query_published_firms
    published_firms
  end

  def query_firms_offering_face_to_face_advice
    published_firms.select { |f| f.other_advice_methods.empty? }
  end

  def query_firms_offering_remote_advice
    published_firms.select { |f| f.in_person_advice_methods.empty? }
  end

  def query_firms_in_england
    firms_in_country(published_firms, 'England')
  end

  def query_firms_in_scotland
    firms_in_country(published_firms, 'Scotland')
  end

  def query_firms_in_wales
    firms_in_country(published_firms, 'Wales')
  end

  def query_firms_in_northern_ireland
    firms_in_country(published_firms, 'Northern Ireland')
  end

  def query_firms_providing_retirement_income_products
    published_firms.select { |f| f.retirement_income_products_flag? }
  end

  def query_firms_providing_pension_transfer
    published_firms.select { |f| f.pension_transfer_flag? }
  end

  def query_firms_providing_long_term_care
    published_firms.select { |f| f.long_term_care_flag? }
  end

  def query_firms_providing_equity_release
    published_firms.select { |f| f.equity_release_flag? }
  end

  def query_firms_providing_inheritance_tax_and_estate_planning
    published_firms.select { |f| f.inheritance_tax_and_estate_planning_flag? }
  end

  def query_firms_providing_wills_and_probate
    published_firms.select { |f| f.wills_and_probate_flag? }
  end

  def query_firms_providing_ethical_investing
    published_firms.select { |f| f.ethical_investing_flag? }
  end

  def query_firms_providing_sharia_investing
    published_firms.select { |f| f.sharia_investing_flag? }
  end

  def query_firms_offering_languages_other_than_english
    published_firms.select { |f| f.languages.present? }
  end

  def query_offices_with_disabled_access
    firm_ids = published_firms.map(&:id)
    Office.includes(:firm).where(disabled_access: true, firms: { id: firm_ids })
  end

  def query_registered_advisers
    Adviser.all
  end

  def query_advisers_in_england
    advisers_in_country(Adviser.all, 'England')
  end

  def query_advisers_in_scotland
    advisers_in_country(Adviser.all, 'Scotland')
  end

  def query_advisers_in_wales
    advisers_in_country(Adviser.all, 'Wales')
  end

  def query_advisers_in_northern_ireland
    advisers_in_country(Adviser.all, 'Northern Ireland')
  end

  def query_advisers_who_travel_5_miles
    Adviser.where(travel_distance: TravelDistance.all['5 miles'])
  end

  def query_advisers_who_travel_10_miles
    Adviser.where(travel_distance: TravelDistance.all['10 miles'])
  end

  def query_advisers_who_travel_25_miles
    Adviser.where(travel_distance: TravelDistance.all['25 miles'])
  end

  def query_advisers_who_travel_50_miles
    Adviser.where(travel_distance: TravelDistance.all['50 miles'])
  end

  def query_advisers_who_travel_100_miles
    Adviser.where(travel_distance: TravelDistance.all['100 miles'])
  end

  def query_advisers_who_travel_150_miles
    Adviser.where(travel_distance: TravelDistance.all['150 miles'])
  end

  def query_advisers_who_travel_250_miles
    Adviser.where(travel_distance: TravelDistance.all['250 miles'])
  end

  def query_advisers_who_travel_uk_wide
    Adviser.where(travel_distance: TravelDistance.all['UK wide'])
  end

  def query_advisers_accredited_in_solla
    Adviser.includes(:accreditations).where(accreditations: { name: 'SOLLA' })
  end

  def query_advisers_accredited_in_later_life_academy
    Adviser.includes(:accreditations).where(accreditations: { name: 'Later Life Academy' })
  end

  def query_advisers_accredited_in_iso22222
    Adviser.includes(:accreditations).where(accreditations: { name: 'ISO 22222' })
  end

  def query_advisers_accredited_in_bs8577
    Adviser.includes(:accreditations).where(accreditations: { name: 'British Standard in Financial Planning BS8577' })
  end

  def query_advisers_with_qualification_in_level_4
    Adviser.includes(:qualifications).where(qualifications: { name: 'Level 4 (DipPFS, DipFA® or equivalent)' })
  end

  def query_advisers_with_qualification_in_level_6
    Adviser.includes(:qualifications).where(qualifications: { name: 'Level 6 (APFS, Adv DipFA®)' })
  end

  def query_advisers_with_qualification_in_chartered_financial_planner
    Adviser.includes(:qualifications).where(qualifications: { name: 'Chartered Financial Planner' })
  end

  def query_advisers_with_qualification_in_certified_financial_planner
    Adviser.includes(:qualifications).where(qualifications: { name: 'Certified Financial Planner' })
  end

  def query_advisers_with_qualification_in_pension_transfer
    Adviser.includes(:qualifications).where(qualifications: {
      name: 'Pension transfer qualifications - holder of G60, AF3, AwPETR®, or equivalent'
    })
  end

  def query_advisers_with_qualification_in_equity_release
    Adviser.includes(:qualifications).where(qualifications: {
      name: 'Equity release qualifications i.e. holder of Certificate in Equity Release or equivalent'
    })
  end

  def query_advisers_with_qualification_in_long_term_care_planning
    Adviser.includes(:qualifications).where(qualifications: {
      name: 'Long term care planning qualifications i.e. holder of CF8, CeLTCI®. or equivalent'
    })
  end

  def query_advisers_with_qualification_in_tep
    Adviser.includes(:qualifications).where(qualifications: {
      name: 'Holder of Trust and Estate Practitioner qualification (TEP) i.e. full member of STEP'
    })
  end

  def query_advisers_with_qualification_in_fcii
    Adviser.includes(:qualifications).where(qualifications: {
      name: 'Fellow of the Chartered Insurance Institute (FCII)'
    })
  end

  def query_advisers_part_of_personal_finance_society
    Adviser.includes(:professional_bodies).where(professional_bodies: {
      name: 'Personal Finance Society / Chartered Insurance Institute'
    })
  end

  def query_advisers_part_of_institute_financial_planning
    Adviser.includes(:professional_bodies).where(professional_bodies: {
      name: 'Institute of Financial Planning'
    })
  end

  def query_advisers_part_of_institute_financial_services
    Adviser.includes(:professional_bodies).where(professional_bodies: {
      name: 'Institute of Financial Services'
    })
  end

  def query_advisers_part_of_ci_bankers_scotland
    Adviser.includes(:professional_bodies).where(professional_bodies: {
      name: 'The Chartered Institute of Bankers in Scotland'
    })
  end

  def query_advisers_part_of_ci_securities_and_investments
    Adviser.includes(:professional_bodies).where(professional_bodies: {
      name: 'The Chartered Institute for Securities and Investments'
    })
  end

  def query_advisers_part_of_cfa_institute
    Adviser.includes(:professional_bodies).where(professional_bodies: {
      name: 'CFA Institute'
    })
  end

  def query_advisers_part_of_chartered_accountants
    Adviser.includes(:professional_bodies).where(professional_bodies: {
      name: 'Institute of Chartered Accountants for England and Wales'
    })
  end

  private

  def advisers_in_country(advisers, country)
    postcodes = advisers.map { |adviser| adviser.postcode }
    country_postcodes = country_postcodes(postcodes, country)
    advisers.select { |adviser| country_postcodes.include?(adviser.postcode) }
  end

  def country_postcodes(postcodes, country)
    map_postcodes_to_country(postcodes)
      .select { |postcode, postcode_country| postcode_country == country }
      .map { |postcode, postcode_country| postcode }
  end

  def firms_in_country(firms, country)
    postcodes = firms.map { |firm| firm.main_office.address_postcode }
    country_postcodes = country_postcodes(postcodes, country)
    firms.select { |firm| country_postcodes.include?(firm.main_office.address_postcode) }
  end

  # Make sure we only request 100 at a time
  def map_postcodes_to_country(postcodes)
    postcodes
      .uniq
      .each_slice(100)
      .map { |slice| map_postcodes_slice_to_country(slice) }
      .reduce(&:merge)
  end

  def map_postcodes_slice_to_country(postcodes)
    request = Net::HTTP::Post.new('/postcodes')
    request.set_form_data(postcodes: postcodes)

    response = Net::HTTP.new('api.postcodes.io').request(request)

    if response.code.to_i == 200
      result = JSON.parse(response.read_body)['result'].map { |r| r['result'] }.compact
      result.each_with_object({}) do |r, obj|
        obj[r['postcode']] = r['country']
      end
    else
      {}
    end
  end

  def published_firms
    @_published_firms ||= Firm.registered.select(&:publishable?)
  end
end
