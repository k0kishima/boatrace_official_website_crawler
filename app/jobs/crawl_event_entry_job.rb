class CrawlEventEntryJob < ApplicationJob
  include FileReloadable
  queue_as :high_priority
  discard_on ::TooFastToCrawl do |_, e|
    Raven.capture_exception(e)
  end
  discard_on ::EventRepository::NotFound do |_, e|
    Raven.capture_exception(e)
  end

  def perform(version:, stadium_tel_code:, event_starts_on:)
    CrawlEventEntryService.call(version: version, stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on, no_cache: no_cache)
  end
end