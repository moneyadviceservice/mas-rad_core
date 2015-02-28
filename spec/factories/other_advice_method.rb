FactoryGirl.define do
  factory :other_advice_method do
    name { Faker::Lorem.sentence }
    sequence(:cy_name) { |n| "Dull gyngor arall #{n}" }
  end
end
