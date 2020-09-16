class BoatBettingContributeRateAggregationRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(boat_betting_contribute_rate_aggregations)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/boat_betting_contribute_rate_aggregations/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            boat_betting_contribute_rate_aggregations: boat_betting_contribute_rate_aggregations.map do |racer_winning_rate_aggregation|
              {
                  stadium_tel_code: racer_winning_rate_aggregation.stadium_tel_code,
                  boat_number: racer_winning_rate_aggregation.boat_number,
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