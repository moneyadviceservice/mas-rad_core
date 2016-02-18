module Snapshot::OfficeQueries
  def query_offices_with_disabled_access
    firm_ids = publishable_firms.map(&:id)
    Office.includes(:firm).where(disabled_access: true, firms: { id: firm_ids })
  end
end
