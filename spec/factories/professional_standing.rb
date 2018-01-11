FactoryBot.define do
  factory :professional_standing do
    sequence(:name) { |n| "Professional Standing #{n}" }
    sequence(:order) { |n| n - 1 }
  end
end
