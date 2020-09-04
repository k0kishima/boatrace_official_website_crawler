class CrawlRacerProfileService
  include ServiceBase

  def call
    RacerRepository.update(racer)
  rescue ::ParserError::DataNotFound
    RacerRepository.make_retire(racer_registration_number)
  end

  private

    attr_accessor :version, :racer_registration_number, :no_cache

    def page
      @page ||= RacerProfilePageRepository.fetch(version: version, racer_registration_number: racer_registration_number, no_cache: no_cache)
    end

    def parser_class
      @parser_class ||= RacerParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
    end

    # 現行バージョンではgenderはこのパーサーで取れないのでここでは属性に入れてない
    Racer = Struct.new(:registration_number, :last_name, :first_name, :term, :birth_date, :branch_prefecture, :born_prefecture, :height, :status, keyword_init: true) do
      def branch_id
        JpPrefecture::Prefecture.find(name: branch_prefecture).try(:code)
      end

      def born_prefecture_id
        JpPrefecture::Prefecture.find(name: born_prefecture).try(:code)
      end
    end
    def racer
      attribute = parser.parse
      Racer.new(
        registration_number: attribute.fetch(:registration_number),
        last_name: attribute.fetch(:last_name),
        first_name: attribute.fetch(:first_name, ''),
        term: attribute.fetch(:term),
        birth_date: attribute.fetch(:birth_date),
        branch_prefecture: attribute.fetch(:branch_prefecture),
        born_prefecture: attribute.fetch(:born_prefecture),
        height: attribute.fetch(:height),
        status: 'active'
      )
    end
end
