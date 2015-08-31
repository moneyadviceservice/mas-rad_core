namespace :firms do
  desc 'Index all existing firms'
  task index: :environment do
    puts 'Do you want to index all existing firms? [type `yes` to confirm]'
    confirmation = STDIN.gets.chomp
    if confirmation.downcase == 'yes'
      puts 'Building firms index...'
      Firm.registered.each { |f| IndexFirmJob.perform_later(f) }
      puts '...indexing done.'
    else
      puts 'Indexing aborted.'
    end
  end
end
