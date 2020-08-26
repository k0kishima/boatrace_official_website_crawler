class CrawlEventScheduleService
  include ServiceBase

  def call
    EventRepository.create_or_update_many(events)
  end

  private

    attr_accessor :version, :year, :month, :no_cache

    def page
      @page ||= EventSchedulePageRepository.fetch(version: version, year: year, month: month, no_cache: no_cache)
    end

    def parser_class
      @parser_class ||= EventParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
    end

    def status
      @status ||= DateTime.new(year, month, 1).in_time_zone.to_date == Time.zone.today ? 'on_going' : 'done'
    end

    Event = Struct.new(:stadium_tel_code, :starts_on, :title, :grade, :kind, :status, keyword_init: true)
    def events
      parser.parse.map do |attributes|
        Event.new(attributes.slice(*Event.members).merge({status: status}))
      end
    end
end