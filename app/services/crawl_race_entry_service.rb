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
                  first_name: attributes.fetch(:racer_first_name))
      end
    end
end
