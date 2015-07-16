FactoryGirl.define do
  sequence(:registered_name) { |n| "Financial Advice #{n} Ltd." }

  factory :firm do
    fca_number
    registered_name
    email_address { Faker::Internet.email }
    telephone_number { Faker::Base.numerify('##### ### ###') }
    website_address { Faker::Internet.url }
    address_line_one { Faker::Address.street_address }
    address_line_two { Faker::Address.secondary_address }
    address_town { Faker::Address.city }
    address_county { Faker::Address.state }
    address_postcode 'EC1N 2TD'
    in_person_advice_methods { create_list(:in_person_advice_method, rand(1..3)) }
    other_advice_methods { create_list(:other_advice_method, rand(1..3)) }
    free_initial_meeting { [true, false].sample }
    initial_meeting_duration { create(:initial_meeting_duration) }
    minimum_fixed_fee { Faker::Number.number(4) }
    initial_advice_fee_structures { create_list(:initial_advice_fee_structure, rand(1..3)) }
    ongoing_advice_fee_structures { create_list(:ongoing_advice_fee_structure, rand(1..3)) }
    allowed_payment_methods { create_list(:allowed_payment_method, rand(1..3)) }
    investment_sizes { create_list(:investment_size, rand(5..10)) }
    retirement_income_products_flag true
    pension_transfer_flag true
    long_term_care_flag true
    equity_release_flag true
    inheritance_tax_and_estate_planning_flag true
    wills_and_probate_flag true
    latitude { Faker::Address.latitude.to_f.round(6) }
    longitude { Faker::Address.longitude.to_f.round(6) }

    factory :trading_name do
      parent factory: Firm

      factory :subsidiary
    end

    factory :firm_with_no_business_split do
      retirement_income_products_flag false
      pension_transfer_flag false
      long_term_care_flag false
      equity_release_flag false
      inheritance_tax_and_estate_planning_flag false
      wills_and_probate_flag false
    end

    factory :firm_with_advisers do
      transient do
        advisers_count 3
      end

      after(:create) do |firm, evaluator|
        create_list(:adviser, evaluator.advisers_count, firm: firm)
      end
    end

    factory :firm_with_trading_names do
      subsidiaries { create_list(:trading_name, 3, fca_number: fca_number) }

      factory :firm_with_subsidiaries
    end

    factory :firm_with_principal do
      principal { create(:principal) }
    end
  end
end
