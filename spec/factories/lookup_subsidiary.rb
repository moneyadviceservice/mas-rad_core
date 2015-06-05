FactoryGirl.define do
  factory :lookup_subsidiary, class: Lookup::TradingName do
    fca_number
    name { Faker::Company.name }
  end
end
