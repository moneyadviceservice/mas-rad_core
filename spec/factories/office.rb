FactoryBot.define do
  factory :office do
    address_line_one { Faker::Address.street_address }
    address_line_two { Faker::Address.secondary_address }
    address_town { Faker::Address.city }
    address_county { Faker::Address.state }
    address_postcode 'EC1N 2TD'
    email_address { Faker::Internet.email }
    telephone_number '07111 333 222'
    disabled_access { [true, false].sample }
    latitude  { Faker::Address.latitude.to_f.round(6) }
    longitude { Faker::Address.longitude.to_f.round(6) }
  end
end
