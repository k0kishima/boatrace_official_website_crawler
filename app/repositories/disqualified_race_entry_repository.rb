class DisqualifiedRaceEntryRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(disqualified_race_entries)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/disqualified_race_entries/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            disqualified_race_entries: disqualified_race_entries.map do |disqualified_race_entry|
              {
                  stadium_tel_code: disqualified_race_entry.stadium_tel_code,
                  date: disqualified_race_entry.date,
                  race_number: disqualified_race_entry.race_number,
                  pit_number: disqualified_race_entry.pit_number,
                  disqualification: disqualified_race_entry.disqualification,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end
