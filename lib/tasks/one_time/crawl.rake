namespace :one_time do
  namespace :crawl do
    desc 'Crawl all data in specified month and year'
    task all_data_of_a_month: :environment do
      year = (ENV['YEAR'].presence || Time.zone.today.year).to_i
      month = (ENV['MONTH'].presence || Time.zone.today.month).to_i
      day = (ENV['DAY_OFFSET'].presence || 1).to_i
      date = Date.new(year, month, day)

      puts 'enqueue job which crawl events...'
      ENV['YEAR'] = year.to_s
      ENV['MONTH'] = month.to_s
      Rake::Task['crawl:events'].execute
      puts "\tDone."

      (date..date.end_of_month).each do |date|
        break if date > Date.today

        ENV['DATE'] = date.to_s

        puts date

        puts "\tenqueue job which crawl event entries..."
        Rake::Task['crawl:bulk:event_entries'].execute
        puts "\t\tdone."

        puts "\tenqueue job which crawl motor renewals..."
        Rake::Task['crawl:bulk:motor_renewals'].execute
        puts "\t\tdone."

        EventHoldingFactory.new(date: date).bulk_create.each do |event_holding|
          puts "\tenqueue job which crawl race data in stadium(tel_code: #{event_holding.stadium_tel_code})"
          (1..12).each do |race_number|
            puts "\t\tat #{race_number}R"

            ENV['STADIUM_TEL_CODE'] = event_holding.stadium_tel_code.to_s
            ENV['RACE_NUMBER'] = race_number.to_s

            puts "\t\t\tenqueue job which crawl race information..."
            Rake::Task['crawl:race'].execute
            puts "\t\t\tenqueue job which crawl race entries..."
            Rake::Task['crawl:race_entries'].execute
            puts "\t\t\tenqueue job which crawl racer conditions..."
            Rake::Task['crawl:racer_conditions'].execute
            puts "\t\t\tenqueue job which crawl weather condition..."
            Rake::Task['crawl:weather_condition_before_race'].execute
            Rake::Task['crawl:weather_condition_after_race'].execute
            puts "\t\t\tenqueue job which crawl race exhibition records..."
            Rake::Task['crawl:race_exhibition_records'].execute
            puts "\t\t\tenqueue job which crawl boat settings..."
            Rake::Task['crawl:boat_settings'].execute
            puts "\t\t\tenqueue job which crawl motor maintenances..."
            Rake::Task['crawl:motor_maintenances'].execute
            puts "\t\t\tenqueue job which crawl race records..."
            Rake::Task['crawl:race_records'].execute
            puts "\t\t\tenqueue job which crawl oddses..."
            Rake::Task['crawl:oddses'].execute
            puts "\t\t\tenqueue job which crawl payoffs..."
            Rake::Task['crawl:payoffs'].execute
            puts "\t\t\t\tdone."

            sleep(1)
          end
        end
      end

      puts "\tdone to crawl all data."
    end
  end
end