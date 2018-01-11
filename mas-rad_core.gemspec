$:.push File.expand_path('../lib/mas', __FILE__)

require 'rad_core/version'

Gem::Specification.new do |s|
  s.name        = 'mas-rad_core'
  s.version     = MAS::RadCore::VERSION
  s.authors     = ['Ben Lovell']
  s.email       = ['benjamin.lovell@gmail.com']
  s.homepage    = 'https://www.moneyadviceservice.org.uk'
  s.summary     = 'MAS RAD Core.'
  s.description = 'Models and logic for the RAD family of products.'
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.2.10'

  s.add_dependency 'active_model_serializers'
  s.add_dependency 'geocoder'
  s.add_dependency 'httpclient'
  s.add_dependency 'language_list'
  s.add_dependency 'pg'
  s.add_dependency 'redis'
  s.add_dependency 'statsd-ruby'
  s.add_dependency 'uk_phone_numbers'
  s.add_dependency 'uk_postcode'

  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-collection_matchers'
  s.add_development_dependency 'timecop'
end
