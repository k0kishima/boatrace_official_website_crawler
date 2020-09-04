class CrawlEventEntryService
  include ServiceBase

  def call
    begin
      # ここではupsertは使わない（パース対象のページから完全データが取れないので使えない）
      RacerRepository.create_many(racers)
    rescue ::ParserError::DataNotFound
      # Hack:
      # ただ単にデータ見つからなかった旨のイベントをエンキューしてそれをハンドラーに処理させた方がいい
      # ここでこのサービスとの依存関係やDataNotFound例外が発生すると節がキャンセルされている可能性があるという知識はこのクラスで持つ必要はない
      CancelEventService.call(stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on)
    end
  end

  private

    attr_accessor :version, :stadium_tel_code, :event_starts_on, :no_cache

    def page
      @page ||= EventEntriesPageRepository.fetch(version: version, stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on, no_cache: no_cache)
    end

    def parser_class
      @parser_class ||= EventEntryParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
    end

    Racer = Struct.new(:registration_number, :last_name, :first_name, :gender, keyword_init: true)
    def racers
      parser.parse.map do |attributes|
        Racer.new(registration_number: attributes.fetch(:racer_registration_number),
                  last_name: attributes.fetch(:racer_last_name),
                  first_name: attributes.fetch(:racer_first_name, ''),
                  gender: attributes.fetch(:racer_gender))
      end
    end
end
