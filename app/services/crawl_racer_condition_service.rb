class CrawlRacerConditionService
  include ServiceBase

  def call
    RacerConditionRepository.create_or_update_many(racer_conditions)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number, :no_cache

    def page
      @page ||= RaceExhibitionInformationPageRepository.fetch(version: version,
                                                              stadium_tel_code: stadium_tel_code,
                                                              race_opened_on: date,
                                                              race_number: race_number,
                                                              no_cache: no_cache)
    end

    def parser_class
      @parser_class ||= RacerConditionParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
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
