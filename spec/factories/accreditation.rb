FactoryGirl.define do
  factory :accreditation do
    sequence(:name) { |n| "Accreditation #{n}" }
    sequence(:order) { |n| n - 1 }
  end
end
