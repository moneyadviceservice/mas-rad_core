module Stats
  def self.increment(*args)
    client.increment(*args) if key
  end

  def self.gauge(*args)
    client.gauge(*args) if key
  end

  def self.client
    $statsd ||= Statsd.new('statsd.hostedgraphite.com', 8125).tap do |n|
      n.namespace = key
    end
  end

  def self.key
    ENV['HOSTEDGRAPHITE_APIKEY']
  end
end
