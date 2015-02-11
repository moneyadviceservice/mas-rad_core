FactoryGirl.define do
  factory :qualification do
    sequence(:name) { |n| "Qualification #{n}" }
  end
end
