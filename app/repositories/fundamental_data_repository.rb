module FundamentalDataRepository
  class BadRequest < ::ActionController::BadRequest; end
  class Unauthorized < ::ActionController::BadRequest; end
  class Forbidden < ::ActionController::BadRequest; end
  class NotFound < ::ActionController::BadRequest; end
  class TooManyRequests < ::ActionController::BadRequest; end
  class InternalServerError < StandardError; end

  BASE_URL = Rails.application.config.x.fundamental_data_repository.api_base_url
  APP_TOKEN = Rails.application.config.x.fundamental_data_repository.application_token

  class << self
    def post_events(events)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/events/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            events: events.map do |event|
              {
                  # HACK: アダプタみたいなクラスに切り出した方がよさそう
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

    private

      def handle_response(response)
        case response.status
        when 200..201 then response.body
        when 400 then raise BadRequest, response.body
        when 401 then raise Unauthorized, response.body
        when 403 then raise Forbidden, response.body
        when 404 then raise NotFound, response.body
        when 429 then raise TooManyRequests, response.body
        when 500 then raise InternalServerError, response.body
        end
      end
  end
end