class CrawlRaceRecordJob < ApplicationJob
  queue_as :low_priority
  discard_on ::ParserError::RaceCanceled do |_, e|
    Raven.capture_exception(e)
  end

  def perform(version:, stadium_tel_code:, date:, race_number:)
    CrawlRaceRecordService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number)
  end
end
