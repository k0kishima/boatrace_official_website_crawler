class CrawlEventEntryService
  include ServiceBase

  def call
    # ここではupsertは使わない（パース対象のページから完全データが取れないので使えない）
    FundamentalDataRepository.create_many_racers(racers)
  end

  private

    attr_accessor :version, :stadium_tel_code, :event_starts_on

    def file
      @file ||= OfficialWebsiteContentRepository.event_entry_file(version: version, stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on)
    end

    def parser_class
      @parser_class ||= EventEntryParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(file)
    end

    Racer = Struct.new(:registration_number, :last_name, :first_name, :gender, keyword_init: true)
    def racers
      parser.parse.map do |attributes|
        Racer.new(registration_number: attributes.fetch(:racer_registration_number),
                  last_name: attributes.fetch(:racer_last_name),
                  first_name: attributes.fetch(:racer_first_name),
                  gender: attributes.fetch(:racer_gender))
      end
    end
end
