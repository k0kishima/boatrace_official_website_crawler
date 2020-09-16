class CrawlMotorBettingContributeRateAggregationService
  include ServiceBase

  def call
    MotorBettingContributeRateAggregationRepository.create_or_update_many(motor_betting_contribute_rate_aggregations)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number, :no_cache

    def page
      @page ||= RaceInformationPageRepository.fetch(version: version,
                                                    stadium_tel_code: stadium_tel_code,
                                                    date: date,
                                                    race_number: race_number,
                                                    no_cache: no_cache)
    end


    def parser_class
      @parser_class ||= RaceEntryParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
    end

    MotorBettingContributeRateAggregation = Struct.new(:stadium_tel_code, :motor_number, :aggregated_on, :quinella_rate, :trio_rate, keyword_init: true)
    def motor_betting_contribute_rate_aggregations
      parser.parse.map do |attributes|
        MotorBettingContributeRateAggregation.new(
            stadium_tel_code: stadium_tel_code,
            aggregated_on: date,
            motor_number: attributes.fetch(:motor_number),
            quinella_rate: attributes.fetch(:quinella_rate_of_motor),
            trio_rate: attributes.fetch(:trio_rate_of_motor),
        )
      end
    end
end