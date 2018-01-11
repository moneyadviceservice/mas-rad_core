FactoryBot.define do
  factory :investment_size do
    name { Faker::Lorem.sentence }
    cy_name { Faker::Lorem.sentence }
  end
end
