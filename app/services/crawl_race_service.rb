class CrawlRaceService
  include ServiceBase

  def call
    FundamentalDataRepository.create_or_update_many_races([race])
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
      @parser_class ||= RaceParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(file)
    end

    Race = Struct.new(:stadium_tel_code, :date, :race_number, :title, :metre, :course_fixed, :use_stabilizer, :deadline_text, :status, keyword_init: true) do
      METRE_PER_LAP = 600
      def betting_deadline_at
        hour, min = deadline_text.split(':').map(&:to_i)
        date.to_datetime.in_time_zone.change(hour: hour, min: min)
      end

      def number_of_laps
        metre / METRE_PER_LAP
      end
    end
    def race
      attributes = parser.parse
      Race.new(stadium_tel_code: stadium_tel_code,
               date: date,
               race_number: race_number,
               title: attributes.fetch(:title),
               metre: attributes.fetch(:metre),
               course_fixed: attributes.fetch(:is_course_fixed),
               use_stabilizer: attributes.fetch(:use_stabilizer),
               deadline_text: attributes.fetch(:deadline),
               status: 'on_going')
    end
end
