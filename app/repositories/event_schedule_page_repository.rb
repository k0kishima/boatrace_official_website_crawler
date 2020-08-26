class EventSchedulePageRepository
  class << self
    def fetch(version: , year: , month: , no_cache: false)
      EventSchedulePage.new(version: version, year: year, month: month, no_cache: no_cache)
    end
  end
end