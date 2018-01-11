require 'active_job'
require 'active_model_serializers'
require 'geocoder'
require 'httpclient'
require 'language_list'
require 'statsd'

module MAS
  module RadCore
    class Engine < ::Rails::Engine
      config.autoload_paths << root.join('lib', 'mas')

      initializer :append_migrations do |app|
        unless app.root.to_s.match root.to_s
          config.paths['db/migrate'].expanded.each do |expanded_path|
            app.config.paths['db/migrate'] << expanded_path
          end
        end
      end

      initializer :factories, after: 'factory_bot.set_factory_paths' do
        if defined?(FactoryBot)
          FactoryBot.definition_file_paths << root.join('spec', 'factories')
        end
      end

      rake_tasks do
        load root.join('lib', 'mas', 'tasks', 'firms', 'index.rake')
        load root.join('lib', 'mas', 'tasks', 'firms', 'audit.rake')
      end
    end
  end
end
