class CrawlMotorRenewalService
  include ServiceBase

  MotorRenewal = Struct.new(:stadium_tel_code, :date, keyword_init: true)
  def call
    return if event_entries.blank?
    return if !event_entries.map(&:quinella_rate_of_motor).all?(&:zero?)
    MotorRenewalRepository.create_or_update_many([MotorRenewal.new(stadium_tel_code: stadium_tel_code, date: event_starts_on)])
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

    EventEntry = Struct.new(:quinella_rate_of_motor, keyword_init: true)
    def event_entries
      parser.parse.map do |attributes|
        EventEntry.new(quinella_rate_of_motor: attributes.fetch(:quinella_rate_of_motor))
      end
    end
end
