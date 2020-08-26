module FundamentalDataRepository
  extend ActiveSupport::Concern

  included do
    class BadRequest < ::ActionController::BadRequest; end
    class Unauthorized < ::ActionController::BadRequest; end
    class Forbidden < ::ActionController::BadRequest; end
    class NotFound < ::ActionController::BadRequest; end
    class TooManyRequests < ::ActionController::BadRequest; end
    class InternalServerError < StandardError; end

    class << self
      BASE_URL = Rails.application.config.x.fundamental_data_repository.api_base_url
      APP_TOKEN = Rails.application.config.x.fundamental_data_repository.application_token

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
end