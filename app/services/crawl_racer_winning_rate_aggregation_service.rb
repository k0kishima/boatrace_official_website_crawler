class CrawlRacerWinningRateAggregationService
  include ServiceBase

  def call
    RacerWinningRateAggregationRepository.create_or_update_many(racer_winning_rate_aggregations)
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

    RacerWinningRateAggregation = Struct.new(:racer_registration_number, :aggregated_on, :rate_in_all_stadium, :rate_in_event_going_stadium, keyword_init: true)
    def racer_winning_rate_aggregations
      parser.parse.map do |attributes|
        RacerWinningRateAggregation.new(
            racer_registration_number: attributes.fetch(:racer_registration_number),
            aggregated_on: date,
            rate_in_all_stadium: attributes.fetch(:whole_country_winning_rate),
            rate_in_event_going_stadium: attributes.fetch(:local_winning_rate)
        )
      end
    end
end