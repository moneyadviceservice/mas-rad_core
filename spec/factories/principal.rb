FactoryBot.define do
  sequence(:fca_number, 100000) { |n| n }

  factory :principal do
    fca_number
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email_address { Faker::Internet.email(first_name) }
    job_title { Faker::Name.title }
    telephone_number '07111 333 222'
    confirmed_disclaimer true

    after(:build) { |p| create(:lookup_firm, fca_number: p.fca_number) }
  end
end
