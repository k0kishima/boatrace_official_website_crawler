class CrawlRacerConditionService
  include ServiceBase

  def call
    FundamentalDataRepository.create_or_update_many_racer_conditions(racer_conditions)
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
      @parser_class ||= RacerConditionParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(file)
    end

    RacerCondition = Struct.new(:racer_registration_number, :date, :weight, :adjust, keyword_init: true)
    def racer_conditions
      parser.parse.map do |attributes|
        RacerCondition.new(racer_registration_number: attributes.fetch(:racer_registration_number),
                           date: date,
                           weight: attributes.fetch(:weight),
                           adjust: attributes.fetch(:adjust))
      end
    end
end
