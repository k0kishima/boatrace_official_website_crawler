class CrawlRaceExhibitionRecordService
  include ServiceBase

  def call
    RaceExhibitionRecordRepository.create_or_update_many(race_exhibition_records)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number, :no_cache

    def page
      @page ||= RaceExhibitionInformationPageRepository.fetch(version: version,
                                                              stadium_tel_code: stadium_tel_code,
                                                              date: date,
                                                              race_number: race_number,
                                                              no_cache: no_cache)
    end

    def parser_class
      @parser_class ||= RaceExhibitionRecordParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
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