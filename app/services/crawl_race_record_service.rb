class CrawlRaceRecordService
  include ServiceBase

  def call
    FundamentalDataRepository.create_or_update_many_race_records(race_records)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number

    def file
      @file ||= OfficialWebsiteContentRepository.race_result_file(version: version,
                                                                  stadium_tel_code: stadium_tel_code,
                                                                  date: date,
                                                                  race_number: race_number)
    end

    def parser_class
      @parser_class ||= RaceRecordParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(file)
    end

    RaceRecord = Struct.new(:stadium_tel_code, :date, :race_number, :pit_number, :course_number, :start_time, :start_order, :time_minute, :time_second, :arrival, :disqualification_mark, keyword_init: true) do
      def signed_start_time
        disqualification == :flying ? -start_time : start_time
      end

      def disqualification
        DisqualificationFactory.create!(disqualification_mark) if disqualification_mark.present?
      end

      def race_time
        return nil if time_minute.blank?
        time_minute * 60 + time_second
      end
    end
    def race_records
      parser.parse.map do |attributes|
        RaceRecord.new(stadium_tel_code: stadium_tel_code,
                       date: date,
                       race_number: race_number,
                       pit_number: attributes.fetch(:pit_number),
                       course_number: attributes.fetch(:start_course),
                       start_time: attributes.fetch(:start_time),
                       start_order: attributes.fetch(:start_order),
                       time_minute: attributes.fetch(:time_minute),
                       time_second: attributes.fetch(:time_second),
                       arrival: attributes.fetch(:arrival))
      end
    end
end