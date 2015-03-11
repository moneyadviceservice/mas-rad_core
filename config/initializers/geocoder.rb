if Rails.env.production?
  require 'redis'

  Geocoder.configure(
    lookup: :google,
    cache: Redis.connect(url: ENV['REDISTOGO_URL'])
  )
end
