FactoryGirl.define do
  factory :professional_standing do
    sequence(:name) { |n| "Professional Standing #{n}" }
  end
end
