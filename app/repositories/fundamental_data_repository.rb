# Hack
#
# FundamentalDataRepository.fetch_events みたいな粒度じゃなくて、
# EventRepository.fetch
# みたいにすべきだった
#
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
    def fetch_events(min_starts_on: , max_starts_on:)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.get do |req|
        req.url 'api/internal/v1/events'
        req.body = {
            access_token: APP_TOKEN,
            min_starts_on: min_starts_on,
            max_starts_on: max_starts_on,
        }
      end
      handle_response(response)
    end

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
                  gender:  racer.try(:gender),
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

    def create_or_update_many_weather_conditions(weather_conditions)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/weather_conditions/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            weather_conditions: weather_conditions.map do |weather_condition|
              {
                  stadium_tel_code: weather_condition.stadium_tel_code,
                  date: weather_condition.date,
                  race_number: weather_condition.race_number,
                  in_performance: weather_condition.in_performance,
                  weather: weather_condition.weather,
                  wind_velocity: weather_condition.wind_velocity,
                  wind_angle: weather_condition.wind_angle,
                  wavelength: weather_condition.wavelength,
                  air_temperature: weather_condition.air_temperature,
                  water_temperature: weather_condition.water_temperature,
              }
            end
        }
      end
      handle_response(response)
      true
    end

    def create_or_update_many_race_exhibition_records(race_exhibition_records)
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

    def create_or_update_many_race_records(race_records)
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

    def create_or_update_many_winning_race_entries(winning_race_entries)
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

    def create_or_update_many_disqualified_race_entries(disqualified_race_entries)
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

    def create_or_update_many_boat_settings(boat_settings)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/boat_settings/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            boat_settings: boat_settings.map do |boat_setting|
              {
                  stadium_tel_code: boat_setting.stadium_tel_code,
                  date: boat_setting.date,
                  race_number: boat_setting.race_number,
                  pit_number: boat_setting.pit_number,
                  boat_number: boat_setting.boat_number,
                  motor_number: boat_setting.motor_number,
                  tilt: boat_setting.tilt,
                  propeller_renewed: boat_setting.propeller_renewed,
              }
            end
        }
      end
      handle_response(response)
      true
    end

    def create_or_update_many_motor_maintenances(motor_maintenances)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/motor_maintenances/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            motor_maintenances: motor_maintenances.map do |motor_maintenance|
              {
                  stadium_tel_code: motor_maintenance.stadium_tel_code,
                  date: motor_maintenance.date,
                  race_number: motor_maintenance.race_number,
                  motor_number: motor_maintenance.motor_number,
                  exchanged_parts: motor_maintenance.exchanged_parts,
                  quantity: motor_maintenance.quantity,
              }
            end
        }
      end
      handle_response(response)
      true
    end

    def create_or_update_many_payoffs(payoffs)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/payoffs/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            payoffs: payoffs.map do |payoff|
              {
                  stadium_tel_code: payoff.stadium_tel_code,
                  date: payoff.date,
                  race_number: payoff.race_number,
                  betting_method: payoff.betting_method,
                  betting_number: payoff.betting_number,
                  amount: payoff.amount,
              }
            end
        }
      end
      handle_response(response)
      true
    end

    def create_or_update_many_oddses(oddses)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/oddses/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            oddses: oddses.map do |odds|
              {
                  stadium_tel_code: odds.stadium_tel_code,
                  date: odds.date,
                  race_number: odds.race_number,
                  betting_method: odds.betting_method,
                  betting_number: odds.betting_number,
                  ratio: odds.ratio,
              }
            end
        }
      end
      handle_response(response)
      true
    end

    def create_or_update_many_motor_renewals(motor_renewals)
      connection = ConnectionBuilder.build(BASE_URL)
      response = connection.post do |req|
        req.url 'api/internal/v1/motor_renewals/create_or_update_many'
        req.body = {
            access_token: APP_TOKEN,
            motor_renewals: motor_renewals.map do |motor_renewal|
              {
                  stadium_tel_code: motor_renewal.stadium_tel_code,
                  date: motor_renewal.date,
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