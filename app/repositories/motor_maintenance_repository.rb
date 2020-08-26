class MotorMaintenanceRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(motor_maintenances)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/motor_maintenances/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            motor_maintenances: motor_maintenances.map do |motor_maintenance|
              {
                  stadium_tel_code: motor_maintenance.stadium_tel_code,
                  date: motor_maintenance.date,
                  race_number: motor_maintenance.race_number,
                  motor_number: motor_maintenance.motor_number,
                  exchanged_parts: motor_maintenance.exchanged_parts,
                  quantity: motor_maintenance.quantity,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end