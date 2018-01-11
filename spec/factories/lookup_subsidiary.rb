FactoryBot.define do
  factory :lookup_subsidiary, class: Lookup::Subsidiary do
    fca_number
    name { Faker::Company.name }
  end
end
