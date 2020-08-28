class CrawlRaceExhibitionRecordJob < ApplicationJob
  queue_as :high_priority

  retry_on ::ParserError::DataNotFound, wait: 1.minutes, attempts: 5
  discard_on ::ParserError::RaceCanceled do |job, _|
    page = RaceExhibitionInformationPageRepository.fetch(**job.arguments.first)
    Notification.new(type: :info).notify("below race canceled.\n#{page.origin_redirection_url}")
  end

  def perform(version:, stadium_tel_code:, date:, race_number:)
    no_cache = attempt_number > 1
    CrawlRaceExhibitionRecordService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number, no_cache: no_cache)
  end
end
