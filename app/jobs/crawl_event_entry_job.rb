class CrawlEventEntryJob < ApplicationJob
  queue_as :high_priority

  def perform(version:, stadium_tel_code:, event_starts_on:)
    CrawlEventEntryService.call(version: version, stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on)
  end
end