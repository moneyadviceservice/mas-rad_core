FactoryGirl.define do
  factory :accreditation do
    sequence(:name) { |n| "Accreditation #{n}" }
  end
end
