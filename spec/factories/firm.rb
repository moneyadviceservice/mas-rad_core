FactoryGirl.define do
  sequence(:registered_name) { |n| "Financial Advice #{n} Ltd." }

  factory :firm, aliases: [:publishable_firm, :onboarded_firm] do
    fca_number
    registered_name
    website_address { Faker::Internet.url }
    in_person_advice_methods { create_list(:in_person_advice_method, rand(1..3)) }
    free_initial_meeting { [true, false].sample }
    initial_meeting_duration { create(:initial_meeting_duration) }
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
    status :independent

    transient do
      offices_count 1
    end

    after(:create) do |firm, evaluator|
      create_list(:office, evaluator.offices_count, firm: firm)
      firm.reload
    end

    transient do
      advisers_count 1
    end

    after(:create) do |firm, evaluator|
      create_list(:adviser, evaluator.advisers_count, firm: firm)
    end

    factory :trading_name, aliases: [:subsidiary] do
      parent factory: :firm
    end

    factory :firm_with_advisers, traits: [:with_advisers]
    factory :firm_without_advisers, traits: [:without_advisers]
    factory :firm_with_offices, traits: [:with_offices]
    factory :firm_without_offices, traits: [:without_offices]
    factory :firm_with_principal, traits: [:with_principal]
    factory :firm_with_no_business_split, traits: [:with_no_business_split]
    factory :firm_with_remote_advice, traits: [:with_remote_advice]
    factory :firm_with_subsidiaries, traits: [:with_trading_names]
    factory :firm_with_trading_names, traits: [:with_trading_names]
    factory :invalid_firm, traits: [:invalid], aliases: [:not_onboarded_firm]

    trait :invalid do
      # Invalidate the marker field without referencing it directly
      __registered false
    end

    trait :with_no_business_split do
      retirement_income_products_flag false
      pension_transfer_flag false
      long_term_care_flag false
      equity_release_flag false
      inheritance_tax_and_estate_planning_flag false
      wills_and_probate_flag false
    end

    trait :with_advisers do
      advisers_count 3
    end

    trait :without_advisers do
      advisers_count 0
    end

    trait :with_principal do
      principal { create(:principal) }
    end

    trait :with_offices do
      offices_count 3
    end

    trait :without_offices do
      offices_count 0
    end

    trait :with_remote_advice do
      other_advice_methods { create_list(:other_advice_method, rand(1..3)) }
      in_person_advice_methods []
    end

    trait :with_trading_names do
      subsidiaries { create_list(:trading_name, 3, fca_number: fca_number) }
    end
  end
end
