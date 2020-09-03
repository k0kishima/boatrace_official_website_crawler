class CrawlRaceRecordJob < ApplicationJob
  include FileReloadable
  queue_as :low_priority

  def perform(version:, stadium_tel_code:, date:, race_number:)
    CrawlRaceRecordService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number, no_cache: no_cache)
  end
end
