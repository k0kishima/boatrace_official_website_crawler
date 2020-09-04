class CrawlPayoffJob < ApplicationJob
  include FileReloadable
  queue_as :low_priority
  discard_on ::ParserError::RaceCanceled

  def perform(version:, stadium_tel_code:, date:, race_number:)
    CrawlPayoffService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number, no_cache: no_cache)
  end
end
