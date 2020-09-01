class CrawlWeatherConditionJob < ApplicationJob
  queue_as :high_priority

  retry_on ::DataInPreparation, wait: 1.minutes, attempts: 5
  discard_on ::ParserError::DataNotFound do |_, e|
    Raven.capture_exception(e)
  end
  discard_on ::ParserError::RaceCanceled do |_, e|
    Raven.capture_exception(e)
  end

  def perform(version:, stadium_tel_code:, date:, race_number: , in_performance:)
    no_cache = attempt_number > 1
    CrawlWeatherConditionService.call(version: version, stadium_tel_code: stadium_tel_code, date: date, race_number: race_number, in_performance: in_performance, no_cache: no_cache)
  end
end