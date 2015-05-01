begin
  require 'bundler/setup'
  require 'bundler/gem_tasks'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)

load 'rails/tasks/engine.rake'
load 'lib/mas/tasks/firms.rake'
load 'lib/mas/tasks/audit.rake'

Bundler::GemHelper.install_tasks

task default: :spec
