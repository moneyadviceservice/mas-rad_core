FactoryBot.define do
  factory :professional_body do
    sequence(:name) { |n| "Professional Body #{n}" }
    sequence(:order) { |n| n - 1 }
  end
end
