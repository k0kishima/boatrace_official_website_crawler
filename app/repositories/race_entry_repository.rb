class RaceEntryRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(race_entries)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/race_entries/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            race_entries: race_entries.map do |race_entry|
              {
                  stadium_tel_code: race_entry.stadium_tel_code,
                  date: race_entry.date,
                  race_number: race_entry.race_number,
                  racer_registration_number: race_entry.racer_registration_number,
                  pit_number: race_entry.pit_number,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end
