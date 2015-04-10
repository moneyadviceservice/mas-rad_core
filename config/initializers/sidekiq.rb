if Rails.env.production?
  Sidekiq.configure_server do |config|
    SIDEKIQ_DB_POOL_SIZE = ENV.fetch('SIDEKIQ_DB_POOL', 25)
    ENV['DATABASE_URL']  = "#{ENV['DATABASE_URL']}?pool=#{SIDEKIQ_DB_POOL_SIZE}"

    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end
end
