class PayoffRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(payoffs)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/payoffs/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            payoffs: payoffs.map do |payoff|
              {
                  stadium_tel_code: payoff.stadium_tel_code,
                  date: payoff.date,
                  race_number: payoff.race_number,
                  betting_method: payoff.betting_method,
                  betting_number: payoff.betting_number,
                  amount: payoff.amount,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end