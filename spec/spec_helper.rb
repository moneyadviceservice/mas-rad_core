ENV['RAILS_ENV'] = 'test'

require_relative 'dummy/config/environment'

require 'rspec/rails'
require 'factory_girl_rails'
require 'faker'
require 'pry'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |f| require f }

ActiveRecord::Migrator.migrations_paths.tap do |paths|
  paths << File.expand_path('../../spec/dummy/db/migrate', __FILE__)
  paths << File.expand_path('../../db/migrate', __FILE__)
end

RSpec.configure do |c|
  c.use_transactional_fixtures = true
  c.order = 'random'
  c.run_all_when_everything_filtered = true
  c.disable_monkey_patching!

  c.include FactoryGirl::Syntax::Methods
end
