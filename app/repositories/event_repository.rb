class EventRepository
  include FundamentalDataRepository

  class << self
    def create_or_update_many(events)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/events/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            events: events.map do |event|
              {
                  stadium_tel_code: event.stadium_tel_code,
                  starts_on: event.starts_on,
                  title: event.title,
                  grade: event.grade,
                  kind: event.kind,
                  status: event.status,
              }
            end
        }
      end
      handle_response(response)
      true
    end
  end
end