class RacerProfilePageRepository
  class << self
    def fetch(version: , racer_registration_number: , no_cache: false)
      RacerProfilePage.new(version: version, registration_number: racer_registration_number, no_cache: no_cache)
    end
  end
end
