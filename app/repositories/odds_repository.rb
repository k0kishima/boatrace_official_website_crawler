class OddsRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(oddses)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/oddses/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            oddses: oddses.map do |odds|
              {
                  stadium_tel_code: odds.stadium_tel_code,
                  date: odds.date,
                  race_number: odds.race_number,
                  betting_method: odds.betting_method,
                  betting_number: odds.betting_number,
                  ratio: odds.ratio,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end