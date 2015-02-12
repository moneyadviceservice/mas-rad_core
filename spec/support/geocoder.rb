require 'geocoder'

Geocoder.configure(:lookup => :test)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'latitude'     => 51.5180697,
      'longitude'    => -0.1085203,
      'address'      => 'London EC1N 2TD, UK',
      'state'        => 'London',
      'country'      => 'United Kingdom',
      'country_code' => 'GB'
    }
  ]
)
