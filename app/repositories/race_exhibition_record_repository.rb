class RaceExhibitionRecordRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(race_exhibition_records)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/race_exhibition_records/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            race_exhibition_records: race_exhibition_records.map do |race_exhibition_record|
              {
                  stadium_tel_code: race_exhibition_record.stadium_tel_code,
                  date: race_exhibition_record.date,
                  race_number: race_exhibition_record.race_number,
                  pit_number: race_exhibition_record.pit_number,
                  course_number: race_exhibition_record.course_number,
                  start_time: race_exhibition_record.signed_start_time,
                  exhibition_time: race_exhibition_record.exhibition_time,
                  exhibition_time_order:race_exhibition_record.exhibition_time_order
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end
