FactoryGirl.define do
  factory :qualification do
    sequence(:name) { |n| "Qualification #{n}" }
    sequence(:order) { |n| n - 1 }
  end
end
