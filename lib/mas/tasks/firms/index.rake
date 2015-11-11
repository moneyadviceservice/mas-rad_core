namespace :firms do
  desc 'Index all existing firms'
  task index: :environment do
    puts "Do you want to index all #{Firm.registered.count} indexable firms? [type `yes` to confirm]"
    confirmation = STDIN.gets.chomp

    if confirmation.downcase == 'yes'
      print 'Building firms index: '

      Firm.registered.each do |f|
        f.notify_indexer
        putc '.'
      end

      puts
      puts 'Indexing done.'
    else
      puts 'Indexing aborted.'
    end
  end
end
