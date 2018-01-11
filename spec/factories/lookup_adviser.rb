FactoryBot.define do
  factory :lookup_adviser, class: Lookup::Adviser do
    reference_number { "XXX#{Faker::Number.number(5)}" }
    name { Faker::Name.name }
  end
end
