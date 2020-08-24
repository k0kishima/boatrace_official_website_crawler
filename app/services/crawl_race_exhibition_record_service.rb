class CrawlRaceExhibitionRecordService
  include ServiceBase

  def call
    FundamentalDataRepository.create_or_update_many_race_exhibition_records(race_exhibition_records)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number

    def file
      @file ||= OfficialWebsiteContentRepository.race_exhibition_information_file(version: version,
                                                                                  stadium_tel_code: stadium_tel_code,
                                                                                  date: date,
                                                                                  race_number: race_number)
    end

    def parser_class
      @parser_class ||= RaceExhibitionRecordParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(file)
    end

    RaceExhibitionRecord = Struct.new(:stadium_tel_code, :date, :race_number, :pit_number, :course_number, :start_time, :exhibition_time, :exhibition_time_order, :is_flying, keyword_init: true) do
      def signed_start_time
        is_flying ? -start_time : start_time
      end
    end
    def race_exhibition_records
      parser.parse.map do |attributes|
        RaceExhibitionRecord.new(stadium_tel_code: stadium_tel_code,
                                 date: date,
                                 race_number: race_number,
                                 pit_number: attributes.fetch(:pit_number),
                                 course_number: attributes.fetch(:start_course),
                                 start_time: attributes.fetch(:start_time),
                                 exhibition_time: attributes.fetch(:exhibition_time),
                                 exhibition_time_order: attributes.fetch(:exhibition_time_order),
                                 is_flying: attributes.fetch(:is_flying))
      end
    end
end
