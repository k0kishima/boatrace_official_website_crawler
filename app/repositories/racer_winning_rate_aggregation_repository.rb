class RacerWinningRateAggregationRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(racer_winning_rate_aggregations)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/racer_winning_rate_aggregations/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            racer_winning_rate_aggregations: racer_winning_rate_aggregations.map do |racer_winning_rate_aggregation|
              {
                  racer_registration_number: racer_winning_rate_aggregation.racer_registration_number,
                  aggregated_on: racer_winning_rate_aggregation.aggregated_on,
                  rate_in_all_stadium: racer_winning_rate_aggregation.rate_in_all_stadium,
                  rate_in_event_going_stadium: racer_winning_rate_aggregation.rate_in_event_going_stadium,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end