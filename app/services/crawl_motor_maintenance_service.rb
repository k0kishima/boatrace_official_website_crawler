class CrawlMotorMaintenanceService
  include ServiceBase

  def call
    FundamentalDataRepository.create_or_update_many_motor_maintenances(motor_maintenances) if motor_maintenances.present?
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

    def motor_maintenance_parser_class
      @motor_maintenance_parser_class ||= MotorMaintenanceParserFactory.create(version)
    end

    def race_information_parser
      @race_information_parser ||= race_information_parser_class.new(race_information_file)
    end

    def motor_maintenance_parser
      @motor_maintenance_parser ||= motor_maintenance_parser_class.new(race_exhibition_information_file)
    end

    MotorMaintenance = Struct.new(:stadium_tel_code, :date, :race_number, :motor_number, :exchanged_parts, :quantity, keyword_init: true)
    def motor_maintenances
      motor_maintenance_parser.parse.map do |attributes|
        pit_number = attributes.fetch(:pit_number)
        attributes.fetch(:parts_exchanges, []).map do |parts_exchange|
          MotorMaintenance.new(stadium_tel_code: stadium_tel_code,
                               date: date,
                               race_number: race_number,
                               motor_number: motor_number_indexed_by_pit_number[pit_number],
                               exchanged_parts: ::MotorPartsFactory.create!(parts_exchange.fetch(:parts_name)),
                               quantity: parts_exchange.fetch(:count))
        end
      end.flatten.compact
    end

    def motor_number_indexed_by_pit_number
      @motor_number_indexed_by_pit_number ||= Hash[race_information_parser.parse.map{|attributes| [attributes.fetch(:pit_number), attributes.fetch(:motor_number)] }]
    end
end
