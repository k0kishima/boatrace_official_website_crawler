class CrawlRaceExhibitionRecordJob < ApplicationJob
  include FileReloadable
  queue_as :high_priority

  retry_on ::ParserError::DataNotFound, wait: 1.minutes, attempts: 5
  discard_on ::ParserError::RaceCanceled do |_, e|
    Raven.capture_exception(e)
  end

  def perform(version:, stadium_tel_code:, date:, race_number:)
    CrawlRaceExhibitionRecordService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number, no_cache: no_cache)
  end
end
