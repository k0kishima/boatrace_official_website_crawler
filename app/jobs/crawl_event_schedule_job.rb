class CrawlEventScheduleJob < ApplicationJob
  queue_as :high_priority

  def perform(version:, year: , month:)
    CrawlEventScheduleService.call(version: version, year: year, month: month)
  end
end