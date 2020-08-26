class CrawlEventScheduleJob < ApplicationJob
  queue_as :high_priority

  def perform(version:, year: , month:)
    no_cache = attempt_number > 1
    CrawlEventScheduleService.call(version: version, year: year, month: month, no_cache: no_cache)
  end
end