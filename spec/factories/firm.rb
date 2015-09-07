FactoryGirl.define do
  sequence(:registered_name) { |n| "Financial Advice #{n} Ltd." }

  factory :firm do
    fca_number
    registered_name
    email_address { Faker::Internet.email }
    telephone_number { Faker::Base.numerify('##### ### ###') }
    website_address { Faker::Internet.url }
    in_person_advice_methods { create_list(:in_person_advice_method, rand(1..3)) }
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
    status :independent

    factory :onboarded_firm

    factory :not_onboarded_firm do
      email_address nil
    end

    factory :trading_name, aliases: [:subsidiary] do
      parent factory: Firm
    end

    factory :firm_with_advisers, traits: [:with_advisers]
    factory :firm_with_offices, traits: [:with_offices]
    factory :firm_with_principal, traits: [:with_principal]
    factory :firm_with_no_business_split, traits: [:with_no_business_split]
    factory :firm_with_remote_advice, traits: [:with_remote_advice]
    factory :firm_with_subsidiaries, traits: [:with_trading_names]
    factory :firm_with_trading_names, traits: [:with_trading_names]

    trait :with_no_business_split do
      retirement_income_products_flag false
      pension_transfer_flag false
      long_term_care_flag false
      equity_release_flag false
      inheritance_tax_and_estate_planning_flag false
      wills_and_probate_flag false
    end

    trait :with_advisers do
      transient do
        advisers_count 3
      end

      after(:create) do |firm, evaluator|
        create_list(:adviser, evaluator.advisers_count, firm: firm)
      end
    end

    trait :with_principal do
      principal { create(:principal) }
    end

    trait :with_offices do
      transient do
        offices_count 3
      end

      after(:create) do |firm, evaluator|
        create_list(:office, evaluator.offices_count, firm: firm)
        firm.reload
      end
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
