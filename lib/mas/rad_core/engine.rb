require 'active_job'
require 'geocoder'
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

      initializer :factories, after: 'factory_girl.set_factory_paths' do
        if defined?(FactoryGirl)
          FactoryGirl.definition_file_paths << root.join('spec', 'factories')
        end
      end
    end
  end
end
