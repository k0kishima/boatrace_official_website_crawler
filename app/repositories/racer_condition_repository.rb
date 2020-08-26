class RacerConditionRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(racer_conditions)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/racer_conditions/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            racer_conditions: racer_conditions.map do |racer_condition|
              {
                  racer_registration_number: racer_condition.racer_registration_number,
                  date: racer_condition.date,
                  weight: racer_condition.weight,
                  adjust: racer_condition.adjust,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end
