FactoryGirl.define do
  factory :professional_body do
    sequence(:name) { |n| "Professional Body #{n}" }
  end
end
