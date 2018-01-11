FactoryBot.define do
  factory :in_person_advice_method do
    sequence(:order) { |i| i }
    name { Faker::Lorem.sentence }
  end
end
