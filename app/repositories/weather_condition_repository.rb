class WeatherRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(weather_conditions)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/weather_conditions/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            weather_conditions: weather_conditions.map do |weather_condition|
              {
                  stadium_tel_code: weather_condition.stadium_tel_code,
                  date: weather_condition.date,
                  race_number: weather_condition.race_number,
                  in_performance: weather_condition.in_performance,
                  weather: weather_condition.weather,
                  wind_velocity: weather_condition.wind_velocity,
                  wind_angle: weather_condition.wind_angle,
                  wavelength: weather_condition.wavelength,
                  air_temperature: weather_condition.air_temperature,
                  water_temperature: weather_condition.water_temperature,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end
