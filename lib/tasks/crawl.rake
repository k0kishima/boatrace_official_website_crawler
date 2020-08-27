namespace :crawl do
  def official_web_site_version
    (ENV['USE_VERSION'].presence || Rails.application.config.x.official_website_proxy.latest_official_website_version).to_i
  end

  def race_params
    {
      date: (ENV['DATE'].presence || Time.zone.today).to_date,
      stadium_tel_code: ENV['STADIUM_TEL_CODE'].to_i,
      race_number: ENV['RACE_NUMBER'].to_i,
    }
  end

  desc 'Crawl event in specified year and month'
  task events: :environment do
    year = (ENV['YEAR'].presence || Time.zone.today.year).to_i
    month = (ENV['MONTH'].presence || Time.zone.today.month).to_i
    date = Date.new(year, month)
    CrawlEventScheduleJob.perform_later(version: official_web_site_version, year: date.year, month: date.month)
  end

  desc 'Crawl event entries on specified date at specified stadium'
  task event_entries: :environment do
    CrawlEventEntryJob.perform_later(version: official_web_site_version,
                                     stadium_tel_code: ENV['STADIUM_TEL_CODE'].to_i,
                                     event_starts_on: (ENV['DATE'].presence || Time.zone.today).to_date)
  end

  desc 'Crawl motor renewal on specified date'
  task motor_renewals: :environment do
    CrawlMotorRenewalService.call(version: official_web_site_version,
                                  stadium_tel_code: ENV['STADIUM_TEL_CODE'].to_i,
                                  event_starts_on: (ENV['DATE'].presence || Time.zone.today).to_date)
  end

  desc 'Crawl information of specified race'
  task race: :environment do
    CrawlRaceService.call(version: official_web_site_version, **race_params)
  end

  desc 'Crawl entries on specified race'
  task race_entries: :environment do
    CrawlRaceEntryService.call(version: official_web_site_version, **race_params)
  end

  desc 'Crawl racer conditions on specified race'
  task racer_conditions: :environment do
    CrawlRacerConditionService.call(version: official_web_site_version, **race_params)
  end

  desc 'Crawl weather condition before race'
  task weather_condition_before_race: :environment do
    CrawlWeatherConditionService.call(version: official_web_site_version, **race_params, in_performance: false)
  end

  desc 'Crawl weather condition after race'
  task weather_condition_after_race: :environment do
    CrawlWeatherConditionService.call(version: official_web_site_version, **race_params, in_performance: true)
  end

  desc 'Crawl exhibition records on specified race'
  task race_exhibition_records: :environment do
    CrawlRaceExhibitionRecordService.call(version: official_web_site_version, **race_params)
  end

  desc 'Crawl records on specified race'
  task race_records: :environment do
    CrawlRaceRecordService.call(version: official_web_site_version, **race_params)
  end

  desc 'Crawl boat settings on specified race'
  task boat_settings: :environment do
    CrawlBoatSettingService.call(version: official_web_site_version, **race_params)
  end

  desc 'Crawl motor maintenance on specified race'
  task motor_maintenances: :environment do
    CrawlMotorMaintenanceService.call(version: official_web_site_version, **race_params)
  end

  desc 'Crawl payoff on specified race'
  task payoffs: :environment do
    CrawlPayoffService.call(version: official_web_site_version, **race_params)
  end

  desc 'Crawl oddses on specified race'
  task oddses: :environment do
    CrawlOddsService.call(version: official_web_site_version, **race_params)
  end

  namespace :bulk do
    desc 'Crawl event entries on specified date'
    task event_entries: :environment do
      date = (ENV['DATE'].presence || Time.zone.today).to_date
      FundamentalDataRepository.fetch_events(min_starts_on: date, max_starts_on: date).each do |attribute|
        begin
          stadium_tel_code = attribute.fetch('stadium_tel_code')
          CrawlEventEntryService.call(version: official_web_site_version,
                                      stadium_tel_code: stadium_tel_code,
                                      event_starts_on: date)
        rescue ParserError::DataNotFound
          puts "\tevent(in stadium_tel_code: #{stadium_tel_code}) was cancelled"
        end
      end
    end

    desc 'Crawl motor renewal on specified date'
    task motor_renewals: :environment do
      date = (ENV['DATE'].presence || Time.zone.today).to_date
      FundamentalDataRepository.fetch_events(min_starts_on: date, max_starts_on: date).each do |attribute|
        begin
          stadium_tel_code = attribute.fetch('stadium_tel_code')
          CrawlMotorRenewalService.call(version: official_web_site_version,
                                        stadium_tel_code: attribute.fetch('stadium_tel_code'),
                                        event_starts_on: date)
        rescue ParserError::DataNotFound
          puts "\tevent(in stadium_tel_code: #{stadium_tel_code}) was cancelled"
        end
      end
    end
  end
end