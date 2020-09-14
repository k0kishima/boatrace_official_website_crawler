class CrawlRaceEntryService
  include ServiceBase

  def call
    # NOTE:
    #
    # 前検情報のページでレーサーは同様に一括登録しているが、追加斡旋者がいる場合そこには載ってないからこのタイミングでとるしかない
    # かなりリクエスト数増えるが冪等性担保してあるのと、レコードの有無の確認にもそもそもリクエスト発生してその方が余計コスト増えるのでこの方式
    # これが一番シンプルなはず（特にかく全員createしにいく・すでにレコードあったら影響がない）
    #
    RacerRepository.create_many(racers)
    RaceEntryRepository.create_or_update_many(race_entries)
    DisqualifiedRaceEntryRepository.create_or_update_many(absent_race_entries) if absent_race_entries.present?
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

    RaceEntry = Struct.new(:stadium_tel_code, :date, :race_number, :racer_registration_number, :pit_number, keyword_init: true)
    def race_entries
      parser.parse.map do |attributes|
        RaceEntry.new(stadium_tel_code: stadium_tel_code,
                      date: date,
                      race_number: race_number,
                      racer_registration_number: attributes.fetch(:racer_registration_number),
                      pit_number: attributes.fetch(:pit_number))
      end
    end

    Racer = Struct.new(:registration_number, :last_name, :first_name, keyword_init: true)
    def racers
      parser.parse.map do |attributes|
        Racer.new(registration_number: attributes.fetch(:racer_registration_number),
                  last_name: attributes.fetch(:racer_last_name),
                  first_name: attributes.fetch(:racer_first_name, ''))
      end
    end

    AbsentRaceEntry = Struct.new(:stadium_tel_code, :date, :race_number, :pit_number, keyword_init: true) do
      def disqualification
        :absent
      end
    end
    def absent_race_entries
      @absent_race_entries ||= parser.parse.select do |attributes|
        attributes.fetch(:is_absent)
      end.map do |attributes|
        AbsentRaceEntry.new(stadium_tel_code: stadium_tel_code,
                            date: date,
                            race_number: race_number,
                            pit_number: attributes.fetch(:pit_number))
      end
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