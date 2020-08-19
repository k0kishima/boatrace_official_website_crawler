class CrawlRaceEntryService
  include ServiceBase

  def call
    FundamentalDataRepository.create_or_update_many_race_entries(race_entries)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number

    def file
      @file ||= OfficialWebsiteContentRepository.race_information_file(version: version,
                                                                       stadium_tel_code: stadium_tel_code,
                                                                       date: date,
                                                                       race_number: race_number)
    end

    def parser_class
      @parser_class ||= RaceEntryParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(file)
    end

    RaceEntry = Struct.new(:stadium_tel_code, :date, :race_number, :racer_registration_number, :pit_number, keyword_init: true)
    def race_entries
      parser.parse.map do |attributes|
        RaceEntry.new(stadium_tel_code: stadium_tel_code,
                      date: date,
                      race_number: race_number,
                      racer_registration_number: attributes.fetch(:racer_registration_number),
                      pit_number: attributes.fetch(:pit_number))
      end
    end
end
