class WeatherConditionParserFactory
  def self.create(version)
    V1707::WeatherConditionParser
  end
end
