class CrawlOddsService
  include ServiceBase

  def call
    OddsRepository.create_or_update_many(oddes)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number, :no_cache

    def page
      @page ||= RaceOddsPageRepository.fetch(version: version,
                                             stadium_tel_code: stadium_tel_code,
                                             date: date,
                                             race_number: race_number,
                                             no_cache: no_cache)
    end

    def parser_class
      @parser_class ||= OddsParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
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