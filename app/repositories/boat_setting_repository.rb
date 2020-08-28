class BoatSettingRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(boat_settings)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/boat_settings/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            boat_settings: boat_settings.map do |boat_setting|
              {
                  stadium_tel_code: boat_setting.stadium_tel_code,
                  date: boat_setting.date,
                  race_number: boat_setting.race_number,
                  pit_number: boat_setting.pit_number,
                  boat_number: boat_setting.boat_number,
                  motor_number: boat_setting.motor_number,
                  tilt: boat_setting.tilt,
                  propeller_renewed: boat_setting.propeller_renewed,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end