class EventEntriesPageRepository
  class << self
    def fetch(version: , stadium_tel_code: , event_starts_on:, no_cache: false)
      EventEntriesPage.new(version: version,
                           stadium_tel_code: stadium_tel_code,
                           event_starts_on: event_starts_on,
                           no_cache: no_cache)
    end
  end
end