FactoryBot.define do
  factory :allowed_payment_method do
    name { Faker::Lorem.sentence }
  end
end
