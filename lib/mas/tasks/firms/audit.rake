require 'csv'

namespace :firms do
  desc 'Audit firms in Elastic against database'

  task audit: :environment do
    puts 'Auditing ES based on database'
    bad_firms = audit_database

    puts "\nAuditing ES for records absent in database"
    absent_firms = audit_es

    report_results(bad_firms, absent_firms)
  end

  def audit_database
    Firm.registered.select do |firm|
      es_firm = FirmRepository.new.find(firm)['_source']
      if es_firm != serialize_firm(firm)
        print '!'
        true
      else
        print '.'
        false
      end
    end
  end

  def audit_es
    ids = Firm.registered.map(&:id)
    all_firms.select do |es_firm|
      if ids.include? es_firm['_source']['_id']
        print '.'
        false
      else
        print '!'
        true
      end
    end
  end

  def report_results(bad_firms, absent_firms)
    if (bad_firms.size + absent_firms.size) > 0
      puts "\nDatabase firms that don't match ES records #{bad_firms.size}"
      puts "Firms in ES that don't exist in database #{absent_firms.size}"
      puts "\nWrote output to /bad_firms.csv"

      write_csv(bad_firms, absent_firms)
    else
      puts 'All good!'
    end
  end

  def write_csv(bad_firms, absent_firms)
    CSV.open('bad_firms.csv', 'wb') do |file|
      file << ['STATUS','ID','NAME']

      bad_firms.each do |firm|
        file << ['ES_WRONG', firm.id, firm.registered_name]
      end

      absent_firms.each do |firm|
        file << ['DB_ABSENT', firm['_source']['_id'], firm['_source']['registered_name']]
      end
    end
  end

  def all_firms
    @all_firms ||= FirmRepository.new.all['hits']['hits']
  end

  def serialize_firm(firm)
    JSON.parse(FirmSerializer.new(firm).to_json)
  end
end
