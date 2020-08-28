class WinningRaceEntryRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(winning_race_entries)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/winning_race_entries/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            winning_race_entries: winning_race_entries.map do |winning_race_entry|
              {
                  stadium_tel_code: winning_race_entry.stadium_tel_code,
                  date: winning_race_entry.date,
                  race_number: winning_race_entry.race_number,
                  pit_number: winning_race_entry.pit_number,
                  winning_trick: winning_race_entry.winning_trick,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end