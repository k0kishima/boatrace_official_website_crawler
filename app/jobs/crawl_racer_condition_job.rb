class CrawlRacerConditionJob < ApplicationJob
  queue_as :high_priority

  def perform(version:, stadium_tel_code:, date:, race_number:)
    CrawlRacerConditionService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number)
  end
end
