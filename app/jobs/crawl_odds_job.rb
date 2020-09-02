class CrawlOddsJob < ApplicationJob
  queue_as :high_priority

  discard_on ::ParserError::DataNotFound do |_, e|
    Raven.capture_exception(e)
  end
  discard_on ::ParserError::RaceCanceled do |_, e|
    Raven.capture_exception(e)
  end

  def perform(version:, stadium_tel_code:, date:, race_number:)
    CrawlOddsService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number)
  end
end
