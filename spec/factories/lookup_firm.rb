FactoryBot.define do
  factory :lookup_firm, class: Lookup::Firm do
    fca_number
    registered_name { Faker::Company.name }
  end
end
