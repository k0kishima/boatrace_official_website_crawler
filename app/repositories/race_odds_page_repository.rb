class RaceOddsPageRepository
  class << self
    def fetch(version: , stadium_tel_code: , race_opened_on: , race_number: , no_cache: false)
      RaceOddsPage.new(version: version,
                       stadium_tel_code: stadium_tel_code,
                       race_opened_on: race_opened_on,
                       race_number: race_number,
                       no_cache: no_cache)
    end
  end
end
