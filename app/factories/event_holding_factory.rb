class EventHoldingFactory
  CANCELED_TEXTS = %w(中止順延	中止)

  def initialize(args = {})
    @version = args.fetch(:version) { Rails.application.config.x.official_website_proxy.latest_official_website_version }
    @date = args.fetch(:date) { Time.zone.today }
  end

  def bulk_create
    parser.parse.reject do |attributes|
      CANCELED_TEXTS.any? {|cancel_text| attributes.fetch(:day_text).include?(cancel_text) }
    end.map do |attributes|
      EventHolding.new(stadium_tel_code: attributes.fetch(:stadium_tel_code),
                       date: date)
    end
  end

  private

    attr_reader :version, :date

    def parser_class
      @parser_class ||= EventHoldingParserFactory.create(version)
    end

    def page
      @page ||= EventHoldingsPageRepository.fetch(version: version, date: date)
    end

    def parser
      @parser ||= parser_class.new(page.file)
    end
end