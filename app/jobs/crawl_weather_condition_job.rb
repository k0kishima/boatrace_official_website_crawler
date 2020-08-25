class CrawlWeatherConditionJob < ApplicationJob
  queue_as :high_priority

  def perform(version:, stadium_tel_code:, date:, race_number: , in_performance:)
    CrawlWeatherConditionService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number, in_performance: in_performance)
  end
end
