module Snapshot::FirmQueries
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

  def query_firms_providing_workplace_financial_advice
    publishable_firms.select { |f| f.workplace_financial_advice_flag? }
  end

  def query_firms_providing_non_uk_residents
    publishable_firms.select { |f| f.non_uk_residents_flag? }
  end

  def query_firms_providing_sharia_investing
    publishable_firms.select { |f| f.sharia_investing_flag? }
  end

  def query_firms_offering_languages_other_than_english
    publishable_firms.select { |f| f.languages.present? }
  end

  private

  def firms_in_country(firms, country)
    postcodes = firms.map { |firm| firm.main_office.address_postcode }
    country_postcodes = Postcode.new.filter_postcodes_by_country(postcodes, country)
    firms.select { |firm| country_postcodes.include?(firm.main_office.address_postcode) }
  end
end
