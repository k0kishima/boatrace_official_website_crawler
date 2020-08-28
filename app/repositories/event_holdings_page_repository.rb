class EventHoldingsPageRepository
  class << self
    def fetch(version: , date: , no_cache: false)
      EventHoldingsPage.new(version: version, date: date, no_cache: no_cache)
    end
  end
end
