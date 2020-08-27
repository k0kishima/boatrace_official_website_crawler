class CrawlEventEntryJob < ApplicationJob
  queue_as :high_priority
  discard_on ::ParserError::DataNotFound do |job, _|
    page = EventEntriesPageRepository.fetch(**job.arguments.first)
    Notification.new(type: :info).notify("below event canceled.\n#{page.origin_redirection_url}")
  end

  def perform(version:, stadium_tel_code:, event_starts_on:)
    CrawlEventEntryService.call(version: version, stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on)
  end
end