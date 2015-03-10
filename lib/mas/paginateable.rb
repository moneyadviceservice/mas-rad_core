module Paginateable
  def total_pages
    if total_records < page_size
      1
    elsif (total_records % page_size).zero?
      total_records / page_size
    else
      (total_records / page_size) + 1
    end
  end

  def total_records
    json['hits']['total']
  end

  def first_record
    return 1 if current_page == 1

    ((current_page - 1) * page_size) + 1
  end

  def last_record
    last = current_page * page_size

    last > total_records ? total_records : last
  end

  def page_size
    MAS::RadCore::PAGE_SIZE
  end
  alias :limit_value :page_size
end
