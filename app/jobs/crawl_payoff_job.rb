class CrawlPayoffJob < ApplicationJob
  queue_as :low_priority

  def perform(version:, stadium_tel_code:, date:, race_number:)
    CrawlPayoffService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number)
  end
end
