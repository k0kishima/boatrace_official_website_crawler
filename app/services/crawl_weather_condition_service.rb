class CrawlWeatherConditionService
  include ServiceBase

  def call
    begin
      WeatherConditionRepository.create_or_update_many([weather_condition])
    rescue ::ParserError::DataNotFound => e
      raise date < Time.zone.today ? e : DataInPreparation.new
    end
  end

  private

    attr_accessor :version, :stadium_tel_code, :date, :race_number, :in_performance, :no_cache

    def race_params
      {
        stadium_tel_code: stadium_tel_code,
        date: date,
        race_number: race_number
      }
    end

    def exhibition_information_page
      RaceExhibitionInformationPageRepository.fetch(version: version, no_cache: no_cache, **race_params)
    end

    def result_page
      RaceResultPageRepository.fetch(version: version, no_cache: no_cache, **race_params)
    end

    def page
      @page ||=  in_performance ? result_page : exhibition_information_page
    end

    def parser_class
      @parser_class ||= WeatherConditionParserFactory.create(version)
    end

    def parser
      @parser ||= parser_class.new(page.file)
    end

    WeatherCondition = Struct.new(:stadium_tel_code, :date, :race_number, :in_performance, :weather, :wind_velocity, :wind_angle, :wavelength, :air_temperature, :water_temperature, keyword_init: true)
    def weather_condition
      attributes = parser.parse
      WeatherCondition.new(stadium_tel_code: stadium_tel_code,
                           date: date,
                           race_number: race_number,
                           in_performance: in_performance,
                           weather: WeatherFactory.create(attributes.fetch(:weather)),
                           wind_velocity: attributes.fetch(:wind_velocity).to_f,
                           wind_angle: attributes.fetch(:wind_angle).to_f,
                           wavelength: attributes.fetch(:wavelength).to_f,
                           air_temperature: attributes.fetch(:air_temperature).to_f,
                           water_temperature: attributes.fetch(:water_temperature).to_f)
    end
end
