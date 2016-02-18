module Snapshot::MetricsInOrder
  def metrics_in_order
    [
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
    ]
  end
end
