class CrawlPayoffService
  include ServiceBase

  def call
    PayoffRepository.create_or_update_many(payoffs)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number, :no_cache

    def page
      @page ||= RaceResultPageRepository.fetch(version: version,
                                               stadium_tel_code: stadium_tel_code,
                                               date: date,
                                               race_number: race_number,
                                               no_cache: no_cache)
    end

    def parser_class
      @parser_class ||= PayoffParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
    end

    Payoff = Struct.new(:stadium_tel_code, :date, :race_number, :betting_method, :betting_number, :amount, keyword_init: true)
    def payoffs
      parser.parse.map do |attributes|
        Payoff.new(stadium_tel_code: stadium_tel_code,
                   date: date,
                   race_number: race_number,
                   betting_method: attributes.fetch(:betting_method),
                   betting_number: attributes.fetch(:betting_number).gsub('-', '').to_i,
                   amount: attributes.fetch(:amount))
      end
    end
end
