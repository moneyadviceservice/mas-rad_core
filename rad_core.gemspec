$:.push File.expand_path('../lib', __FILE__)

require 'rad_core/version'

Gem::Specification.new do |s|
  s.name        = 'rad_core'
  s.version     = RadCore::VERSION
  s.authors     = ['Ben Lovell']
  s.email       = ['benjamin.lovell@gmail.com']
  s.homepage    = 'https://www.moneyadviceservice.org.uk'
  s.summary     = 'RAD Core.'
  s.description = 'Models and logic for the RAD family of products.'
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.2.0'

  s.add_dependency 'pg'

  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-collection_matchers'
  s.add_development_dependency 'timecop'
end
