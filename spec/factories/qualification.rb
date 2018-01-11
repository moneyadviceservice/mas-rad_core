FactoryBot.define do
  factory :qualification do
    sequence(:name) { |n| "Qualification #{n}" }
    sequence(:order) { |n| n }
  end
end
