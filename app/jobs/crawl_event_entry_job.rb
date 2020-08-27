class CrawlEventEntryJob < ApplicationJob
  queue_as :high_priority

  # TODO:
  # data not found と cancel を区別したい
  # 前者は時系列的にデータ自体が存在しない（公開されていない情報を閲覧しようとしたとか）
  # 後者はイベントやレースの中止によってデータが存在しない
  discard_on ::ParserError::DataNotFound do |job, _|
    page = EventEntriesPageRepository.fetch(**job.arguments.first)
    Notification.new(type: :info).notify("below event canceled.\n#{page.origin_redirection_url}")
  end

  def perform(version:, stadium_tel_code:, event_starts_on:)
    CrawlEventEntryService.call(version: version, stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on)
  end
end