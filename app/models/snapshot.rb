class Snapshot < ActiveRecord::Base
  include Snapshot::MetricsInOrder
  include Snapshot::AdviserQueries
  include Snapshot::FirmQueries
  include Snapshot::OfficeQueries

  def run_queries_and_save
    run_queries
    save
  end

  private

  def publishable_firms
    @_publishable_firms ||= Firm.registered.select(&:publishable?)
  end

  # 1. Gets all public methods
  # 2. Filters those to only include methods beginning with 'query_'
  # 3. For each of those, find the related attribute (remove the 'query_' from the method name)
  # 4. Run the query method, count the return value, and set that to the related attribute
  def run_queries
    public_methods(false)
      .select { |method| method.to_s.starts_with?('query_') }
      .each do |query_method|
        related_attribute = query_method.to_s.sub('query_', '')
        result = send(query_method)
        send("#{related_attribute}=", result.count)
      end
  end
end
