class CrawlRaceRecordService
  include ServiceBase

  def call
    begin
      RaceRecordRepository.create_or_update_many(race_records)
      WinningRaceEntryRepository.create_or_update_many(winning_race_entries)
      DisqualifiedRaceEntryRepository.create_or_update_many(disqualified_race_entries) if disqualified_race_entries.present?
    rescue
      RaceRepository.make_canceled(stadium_tel_code: stadium_tel_code, date: date, race_number: race_number)
      Notification.new(type: :info).notify("below race canceled.\n#{page.origin_redirection_url}")
    end
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
      @parser_class ||= RaceRecordParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
    end

    RaceRecord = Struct.new(:stadium_tel_code, :date, :race_number, :pit_number, :course_number, :start_time, :start_order, :time_minute, :time_second, :arrival, :disqualification_mark, keyword_init: true) do
      def signed_start_time
        disqualification == :flying ? -start_time : start_time
      end

      def disqualification
        DisqualificationFactory.create!(disqualification_mark) if disqualification_mark.present?
      end

      def race_time
        return nil if time_minute.blank?
        time_minute * 60 + time_second
      end
    end
    def race_records
      parser.parse.map do |attributes|
        RaceRecord.new(stadium_tel_code: stadium_tel_code,
                       date: date,
                       race_number: race_number,
                       pit_number: attributes.fetch(:pit_number),
                       course_number: attributes.fetch(:start_course),
                       start_time: attributes.fetch(:start_time),
                       start_order: attributes.fetch(:start_order),
                       time_minute: attributes.fetch(:time_minute),
                       time_second: attributes.fetch(:time_second),
                       arrival: attributes.fetch(:arrival))
      end
    end

    WinningRaceEntry = Struct.new(:stadium_tel_code, :date, :race_number, :pit_number, :winning_trick_name, keyword_init: true) do
      def winning_trick
        WinningTrickFactory.create!(winning_trick_name)
      end
    end
    def winning_race_entries
      parser.parse.select do |attributes|
        attributes.fetch(:winning_trick_name, nil).present?
      end.map do |attributes|
        WinningRaceEntry.new(stadium_tel_code: stadium_tel_code,
                             date: date,
                             race_number: race_number,
                             pit_number: attributes.fetch(:pit_number),
                             winning_trick_name: attributes.fetch(:winning_trick_name))
      end
    end

    DisqualifiedRaceEntry = Struct.new(:stadium_tel_code, :date, :race_number, :pit_number, :disqualification_mark, keyword_init: true) do
      def disqualification
        DisqualificationFactory.create!(disqualification_mark)
      end
    end
    def disqualified_race_entries
      parser.parse.select do |attributes|
        attributes.fetch(:disqualification_mark, nil).present?
      end.map do |attributes|
        DisqualifiedRaceEntry.new(stadium_tel_code: stadium_tel_code,
                                  date: date,
                                  race_number: race_number,
                                  pit_number: attributes.fetch(:pit_number),
                                  disqualification_mark: attributes.fetch(:disqualification_mark))
      end
    end
end