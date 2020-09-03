class CrawlBoatSettingService
  include ServiceBase

  def call
    begin
      BoatSettingRepository.create_or_update_many(boat_settings)
    rescue ::ParserError::DataNotFound => e
      raise date < Time.zone.today ? e : DataInPreparation.new
    end
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number, :no_cache

    def race_information_page
      @race_information_page ||= RaceInformationPageRepository.fetch(version: version,
                                                                     stadium_tel_code: stadium_tel_code,
                                                                     date: date,
                                                                     race_number: race_number,
                                                                     no_cache: no_cache)
    end

    def race_exhibition_information_page
      @race_exhibition_information_page ||= RaceExhibitionInformationPageRepository.fetch(version: version,
                                                                                          stadium_tel_code: stadium_tel_code,
                                                                                          date: date,
                                                                                          race_number: race_number,
                                                                                          no_cache: no_cache)
    end

    def race_information_parser_class
      @race_information_parser_class ||= RaceEntryParserFactory.create(version)
    end

    def boat_setting_parser_class
      @boat_setting_parser_class ||= BoatSettingParserFactory.create(version)
    end

    def race_information_parser
      @race_information_parser ||= race_information_parser_class.new(race_information_page.file)
    end

    def boat_setting_parser
      @boat_setting_parser ||= boat_setting_parser_class.new(race_exhibition_information_page.file)
    end

    BoatSetting = Struct.new(:stadium_tel_code, :date, :race_number, :pit_number, :boat_number, :motor_number, :tilt, :propeller_renewed, keyword_init: true)
    def boat_settings
      race_information_parser.parse.map do |attributes|
        begin
          pit_number = attributes.fetch(:pit_number)
          BoatSetting.new(stadium_tel_code: stadium_tel_code,
                          date: date,
                          race_number: race_number,
                          pit_number: pit_number,
                          boat_number: attributes.fetch(:boat_number),
                          motor_number: attributes.fetch(:motor_number),
                          tilt: tilt_indexed_by_pit_number.fetch(pit_number),
                          propeller_renewed: propeller_renewed_indexed_by_pit_number.fetch(pit_number))
        rescue IndexError
          nil
        end
      end.compact
    end

    def tilt_indexed_by_pit_number
      @tilt_indexed_by_pit_number ||= Hash[boat_setting_parser.parse.map{|attributes| [attributes.fetch(:pit_number), attributes.fetch(:tilt)] }]
    end

    def propeller_renewed_indexed_by_pit_number
      @propeller_renewed_indexed_by_pit_number ||= Hash[boat_setting_parser.parse.map{|attributes| [attributes.fetch(:pit_number), attributes.fetch(:is_new_propeller)] }]
    end

end