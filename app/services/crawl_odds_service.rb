class CrawlOddsService
  include ServiceBase

  def call
    FundamentalDataRepository.create_or_update_many_oddses(oddes)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number

    def file
      @file ||= OfficialWebsiteContentRepository.race_odds_file(version: version,
                                                                stadium_tel_code: stadium_tel_code,
                                                                date: date,
                                                                race_number: race_number)
    end

    def parser_class
      @parser_class ||= OddsParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(file)
    end

    Odds = Struct.new(:stadium_tel_code, :date, :race_number, :betting_method, :betting_number, :ratio, keyword_init: true)
    def oddes
      parser.parse.map do |attributes|
        Odds.new(stadium_tel_code: stadium_tel_code,
                 date: date,
                 race_number: race_number,
                 betting_method: :trifecta,
                 betting_number: attributes.fetch(:betting_number),
                 ratio: attributes.fetch(:ratio))
      end
    end
end