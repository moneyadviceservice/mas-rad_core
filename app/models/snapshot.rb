class Snapshot < ActiveRecord::Base
  before_create :run_queries

  def query_firms_with_no_minimum_fee
    published_firms.select { |f| [0, nil].include?(f.minimum_fixed_fee) }
  end

  private

  def published_firms
    @_published_firms ||= Firm.registered.select(&:publishable?)
  end

  def run_queries
    self.firms_with_no_minimum_fee = query_firms_with_no_minimum_fee.count
  end
end
