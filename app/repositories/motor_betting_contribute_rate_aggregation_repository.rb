class MotorBettingContributeRateAggregationRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(motor_betting_contribute_rate_aggregations)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/motor_betting_contribute_rate_aggregations/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            motor_betting_contribute_rate_aggregations: motor_betting_contribute_rate_aggregations.map do |racer_winning_rate_aggregation|
              {
                  stadium_tel_code: racer_winning_rate_aggregation.stadium_tel_code,
                  motor_number: racer_winning_rate_aggregation.motor_number,
                  aggregated_on: racer_winning_rate_aggregation.aggregated_on,
                  quinella_rate: racer_winning_rate_aggregation.quinella_rate,
                  trio_rate: racer_winning_rate_aggregation.trio_rate,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end