FactoryBot.define do
  factory :other_advice_method do
    name { Faker::Lorem.sentence }
    cy_name { Faker::Lorem.sentence }
  end
end
