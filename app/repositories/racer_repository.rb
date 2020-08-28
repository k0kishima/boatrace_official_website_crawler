class RacerRepository
  include FundamentalDataRepository

  class << self
    def create_many(racers)
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

    def update(racer)
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

    def make_retire(racer_registration_number)
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
  end
end
