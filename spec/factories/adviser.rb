FactoryGirl.define do
  sequence(:reference_number, 10000) { |n| "ABC#{n}" }

  factory :adviser do
    reference_number
    name 'Ben Lovell'
    postcode 'RG1 1NN'
    travel_distance '50'
    latitude  { Faker::Address.latitude.to_f.round(6) }
    longitude { Faker::Address.longitude.to_f.round(6) }
    confirmed_disclaimer true
    firm

    after(:build) do |a|
      if a.reference_number?
        Lookup::Adviser.create!(
          reference_number: a.reference_number,
          name: a.name
        )
      end
    end
  end
end
