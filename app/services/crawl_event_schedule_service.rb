class CrawlEventScheduleService
  include ServiceBase

  def call
    FundamentalDataRepository.post_events(events)
  end

  private

    attr_accessor :version, :year, :month

    def file
      @file ||= OfficialWebsiteContentRepository.event_schedule_file(version: version, year: year, month: month)
    end

    def parser_class
      @parser_class ||= EventParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(file)
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