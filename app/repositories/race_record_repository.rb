class RaceRecordRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(race_records)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/race_records/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            race_records: race_records.map do |race_record|
              {
                  stadium_tel_code: race_record.stadium_tel_code,
                  date: race_record.date,
                  race_number: race_record.race_number,
                  pit_number: race_record.pit_number,
                  course_number: race_record.course_number,
                  start_time: race_record.signed_start_time,
                  start_order: race_record.start_order,
                  race_time: race_record.race_time,
                  arrival: race_record.arrival,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end