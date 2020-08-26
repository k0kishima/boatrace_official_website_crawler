class RaceInformationPageRepository
  class << self
    def fetch(version: , stadium_tel_code: , race_opened_on: , race_number: , no_cache: false)
      RaceInformationPage.new(version: version,
                              stadium_tel_code: stadium_tel_code,
                              race_opened_on: race_opened_on,
                              race_number: race_number,
                              no_cache: no_cache)
    end
  end
end