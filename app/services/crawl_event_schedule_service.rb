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

    Event = Struct.new(:stadium_tel_code, :starts_on, :title, :grade, :kind, :status, keyword_init: true)
    def events
      parser.parse.map do |attributes|
        # status は done と on_going で分けてたけど後者の使い道がなかった
        Event.new(attributes.slice(*Event.members).merge({status: 'done'}))
      end
    end
end