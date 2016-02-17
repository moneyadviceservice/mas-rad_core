require 'net/http'

class Snapshot < ActiveRecord::Base
  def query_firms_with_no_minimum_fee
    publishable_firms.select { |f| [0, nil].include?(f.minimum_fixed_fee) }
  end

  def query_firms_with_min_fee_between_1_500
    publishable_firms.select { |f| (1..500).include?(f.minimum_fixed_fee) }
  end

  def query_firms_with_min_fee_between_501_1000
    publishable_firms.select { |f| (501..1000).include?(f.minimum_fixed_fee) }
  end

  def query_firms_any_pot_size
    under_50k_size = InvestmentSize.find_by(name: 'Under £50,000')
    publishable_firms.select { |f| f.investment_sizes.exists?(under_50k_size.id) }
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
    publishable_firms
  end

  def query_firms_offering_face_to_face_advice
    publishable_firms.select { |f| f.other_advice_methods.empty? }
  end

  def query_firms_offering_remote_advice
    publishable_firms.select { |f| f.in_person_advice_methods.empty? }
  end

  def query_firms_in_england
    firms_in_country(publishable_firms, 'England')
  end

  def query_firms_in_scotland
    firms_in_country(publishable_firms, 'Scotland')
  end

  def query_firms_in_wales
    firms_in_country(publishable_firms, 'Wales')
  end

  def query_firms_in_northern_ireland
    firms_in_country(publishable_firms, 'Northern Ireland')
  end

  def query_firms_providing_retirement_income_products
    publishable_firms.select { |f| f.retirement_income_products_flag? }
  end

  def query_firms_providing_pension_transfer
    publishable_firms.select { |f| f.pension_transfer_flag? }
  end

  def query_firms_providing_long_term_care
    publishable_firms.select { |f| f.long_term_care_flag? }
  end

  def query_firms_providing_equity_release
    publishable_firms.select { |f| f.equity_release_flag? }
  end

  def query_firms_providing_inheritance_tax_and_estate_planning
    publishable_firms.select { |f| f.inheritance_tax_and_estate_planning_flag? }
  end

  def query_firms_providing_wills_and_probate
    publishable_firms.select { |f| f.wills_and_probate_flag? }
  end

  def query_firms_providing_ethical_investing
    publishable_firms.select { |f| f.ethical_investing_flag? }
  end

  def query_firms_providing_sharia_investing
    publishable_firms.select { |f| f.sharia_investing_flag? }
  end

  def query_firms_offering_languages_other_than_english
    publishable_firms.select { |f| f.languages.present? }
  end

  def query_offices_with_disabled_access
    firm_ids = publishable_firms.map(&:id)
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

  TravelDistance.all.keys.each do |val|
    method_name = val.downcase.gsub(' ', '_')
    define_method "query_advisers_who_travel_#{method_name}" do
      advisers_who_travel(val)
    end
  end

  def query_advisers_accredited_in_solla
    advisers_with_accreditation('SOLLA')
  end

  def query_advisers_accredited_in_later_life_academy
    advisers_with_accreditation('Later Life Academy')
  end

  def query_advisers_accredited_in_iso22222
    advisers_with_accreditation('ISO 22222')
  end

  def query_advisers_accredited_in_bs8577
    advisers_with_accreditation('British Standard in Financial Planning BS8577')
  end

  def query_advisers_with_qualification_in_level_4
    advisers_with_qualification('Level 4 (DipPFS, DipFA® or equivalent)')
  end

  def query_advisers_with_qualification_in_level_6
    advisers_with_qualification('Level 6 (APFS, Adv DipFA®)')
  end

  def query_advisers_with_qualification_in_chartered_financial_planner
    advisers_with_qualification('Chartered Financial Planner')
  end

  def query_advisers_with_qualification_in_certified_financial_planner
    advisers_with_qualification('Certified Financial Planner')
  end

  def query_advisers_with_qualification_in_pension_transfer
    advisers_with_qualification('Pension transfer qualifications - holder of G60, AF3, AwPETR®, or equivalent')
  end

  def query_advisers_with_qualification_in_equity_release
    advisers_with_qualification('Equity release qualifications i.e. holder of Certificate in Equity Release or equivalent')
  end

  def query_advisers_with_qualification_in_long_term_care_planning
    advisers_with_qualification('Long term care planning qualifications i.e. holder of CF8, CeLTCI®. or equivalent')
  end

  def query_advisers_with_qualification_in_tep
    advisers_with_qualification('Holder of Trust and Estate Practitioner qualification (TEP) i.e. full member of STEP')
  end

  def query_advisers_with_qualification_in_fcii
    advisers_with_qualification('Fellow of the Chartered Insurance Institute (FCII)')
  end

  def query_advisers_part_of_personal_finance_society
    advisers_part_of('Personal Finance Society / Chartered Insurance Institute')
  end

  def query_advisers_part_of_institute_financial_planning
    advisers_part_of('Institute of Financial Planning')
  end

  def query_advisers_part_of_institute_financial_services
    advisers_part_of('Institute of Financial Services')
  end

  def query_advisers_part_of_ci_bankers_scotland
    advisers_part_of('The Chartered Institute of Bankers in Scotland')
  end

  def query_advisers_part_of_ci_securities_and_investments
    advisers_part_of('The Chartered Institute for Securities and Investments')
  end

  def query_advisers_part_of_cfa_institute
    advisers_part_of('CFA Institute')
  end

  def query_advisers_part_of_chartered_accountants
    advisers_part_of('Institute of Chartered Accountants for England and Wales')
  end

  def run_queries_and_save
    run_queries
    save
  end

  private

  def advisers_in_country(advisers, country)
    postcodes = advisers.map { |adviser| adviser.postcode }
    country_postcodes = country_postcodes(postcodes, country)
    advisers.select { |adviser| country_postcodes.include?(adviser.postcode) }
  end

  def advisers_part_of(professional_body)
    Adviser.includes(:professional_bodies).where(professional_bodies: { name: professional_body })
  end

  def advisers_who_travel(distance)
    Adviser.where(travel_distance: TravelDistance.all[distance])
  end

  def advisers_with_accreditation(accreditation)
    Adviser.includes(:accreditations).where(accreditations: { name: accreditation })
  end

  def advisers_with_qualification(qualification)
    Adviser.includes(:qualifications).where(qualifications: { name: qualification })
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

  def publishable_firms
    @_publishable_firms ||= Firm.registered.select(&:publishable?)
  end

  def run_queries
    public_methods(false)
      .select { |method| method.to_s.starts_with?('query_') }
      .each do |query_method|
        related_attribute = query_method.to_s.sub('query_', '')
        result = send(query_method)
        send("#{related_attribute}=", result.count)
      end
  end
end
