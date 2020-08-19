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
    def create_many_racers(racers)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/racers/create_many'
        req.body = {
            access_token: APP_TOKEN,
            racers: racers.map do |racer|
              {
                  # HACK: アダプタみたいなクラスに切り出した方がよさそう
                  registration_number: racer.registration_number,
                  last_name: racer.last_name,
                  first_name: racer.first_name,
                  gender:  racer.gender,
              }
            end
        }
      end
      handle_response(response)
      true
    end

    def update_racer(racer)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/racers/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            racers: [
              # 現行バージョンではgenderはこのメソッドコールするパーサーで取れないのでここでは属性に入れてない
              {
                  registration_number: racer.registration_number,
                  last_name: racer.last_name,
                  first_name: racer.first_name,
                  term: racer.term,
                  birth_date: racer.birth_date,
                  branch_id: racer.branch_id,
                  birth_prefecture_id: racer.born_prefecture_id,
                  height: racer.height,
                  status: racer.status,
              }
            ]
        }
      end
      handle_response(response)
      true
    end

    def make_racer_retire(racer_registration_number)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.patch do |req|
        req.url "api/internal/v1/racers/#{racer_registration_number}/retire"
        req.body = {
            access_token: APP_TOKEN,
        }
      end
      handle_response(response)
      true
    end

    def create_or_update_many_events(events)
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

    def create_or_update_many_races(races)
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

    def create_or_update_many_race_entries(race_entries)
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

    def create_or_update_many_racer_conditions(racer_conditions)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/racer_conditions/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            racer_conditions: racer_conditions.map do |racer_condition|
              {
                  racer_registration_number: racer_condition.racer_registration_number,
                  date: racer_condition.date,
                  weight: racer_condition.weight,
                  adjust: racer_condition.adjust,
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