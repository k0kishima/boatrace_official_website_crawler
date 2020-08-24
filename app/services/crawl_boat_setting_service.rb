class CrawlBoatSettingService
  include ServiceBase

  def call
    FundamentalDataRepository.create_or_update_many_boat_settings(boat_settings)
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number

    def race_information_file
      @race_information_file ||= OfficialWebsiteContentRepository.race_information_file(version: version,
                                                                                        stadium_tel_code: stadium_tel_code,
                                                                                        date: date,
                                                                                        race_number: race_number)
    end

    def race_exhibition_information_file
      @race_exhibition_information_file ||= OfficialWebsiteContentRepository.race_exhibition_information_file(version: version,
                                                                                                              stadium_tel_code: stadium_tel_code,
                                                                                                              date: date,
                                                                                                              race_number: race_number)
    end

    def race_information_parser_class
      @race_information_parser_class ||= RaceEntryParserFactory.create(version)
    end

    def boat_setting_parser_class
      @boat_setting_parser_class ||= BoatSettingParserFactory.create(version)
    end

    def race_information_parser
      @race_information_parser ||= race_information_parser_class.new(race_information_file)
    end

    def boat_setting_parser
      @boat_setting_parser ||= boat_setting_parser_class.new(race_exhibition_information_file)
    end

    BoatSetting = Struct.new(:stadium_tel_code, :date, :race_number, :pit_number, :boat_number, :motor_number, :tilt, :propeller_renewed, keyword_init: true)
    def boat_settings
      race_information_parser.parse.map do |attributes|
        pit_number = attributes.fetch(:pit_number)
        BoatSetting.new(stadium_tel_code: stadium_tel_code,
                        date: date,
                        race_number: race_number,
                        pit_number: pit_number,
                        boat_number: attributes.fetch(:boat_number),
                        motor_number: attributes.fetch(:motor_number),
                        tilt: tilt_indexed_by_pit_number[pit_number],
                        propeller_renewed: propeller_renewed_indexed_by_pit_number[pit_number])
      end
    end

    def tilt_indexed_by_pit_number
      @tilt_indexed_by_pit_number ||= Hash[boat_setting_parser.parse.map{|attributes| [attributes.fetch(:pit_number), attributes.fetch(:tilt)] }]
    end

    def propeller_renewed_indexed_by_pit_number
      @propeller_renewed_indexed_by_pit_number ||= Hash[boat_setting_parser.parse.map{|attributes| [attributes.fetch(:pit_number), attributes.fetch(:is_new_propeller)] }]
    end

end