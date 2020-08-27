class CrawlEventEntryService
  include ServiceBase

  def call
    # ここではupsertは使わない（パース対象のページから完全データが取れないので使えない）
    RacerRepository.create_many(racers)
  end

  private

    attr_accessor :version, :stadium_tel_code, :event_starts_on, :no_cache

    def page
      @page ||= EventEntriesPageRepository.fetch(version: version, stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on, no_cache: no_cache)
    end

    def parser_class
      @parser_class ||= EventEntryParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
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
