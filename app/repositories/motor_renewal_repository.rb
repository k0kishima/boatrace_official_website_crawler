class MotorRenewalRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(motor_renewals)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/motor_renewals/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            motor_renewals: motor_renewals.map do |motor_renewal|
              {
                  stadium_tel_code: motor_renewal.stadium_tel_code,
                  date: motor_renewal.date,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end