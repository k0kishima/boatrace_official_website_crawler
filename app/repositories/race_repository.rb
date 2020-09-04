class RaceRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(races)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/races/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            races: races.map do |race|
              {
                  stadium_tel_code: race.stadium_tel_code,
                  date: race.date,
                  race_number: race.race_number,
                  title: race.title,
                  number_of_laps: race.number_of_laps,
                  course_fixed: race.course_fixed,
                  use_stabilizer: race.use_stabilizer,
                  betting_deadline_at: race.betting_deadline_at,
                  status: race.status,
              }
            end
        }
      end
      handle_response(response)
      true
    end

    def make_canceled(stadium_tel_code:, date:, race_number:)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.patch do |req|
        req.url 'api/internal/v1/races/cancel'
        req.body = {
            access_token: APP_TOKEN,
            stadium_tel_code: stadium_tel_code,
            date: date,
            race_number: race_number,
        }
      end
      handle_response(response)
      true
    end
  end
end
