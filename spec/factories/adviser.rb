FactoryBot.define do
  sequence(:reference_number, 10000) { |n| "ABC#{n}" }

  factory :adviser do
    transient do
      create_linked_lookup_advisor true
    end

    reference_number
    name { Faker::Name.name }
    postcode { Faker::Address.postcode }
    travel_distance '650'
    latitude  { Faker::Address.latitude.to_f.round(6) }
    longitude { Faker::Address.longitude.to_f.round(6) }
    firm factory: :firm_without_advisers
    bypass_reference_number_check false

    after(:build) do |a, evaluator|
      if a.reference_number? && evaluator.create_linked_lookup_advisor
        Lookup::Adviser.create!(
          reference_number: a.reference_number,
          name: a.name
        )
      end
    end
  end
end
