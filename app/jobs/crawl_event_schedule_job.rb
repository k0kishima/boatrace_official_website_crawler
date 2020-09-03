class CrawlEventScheduleJob < ApplicationJob
  include FileReloadable
  queue_as :high_priority

  def perform(version:, year: , month:)
    CrawlEventScheduleService.call(version: version, year: year, month: month, no_cache: no_cache)
  end
end