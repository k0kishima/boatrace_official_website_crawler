class CrawlMotorRenewalJob < ApplicationJob
  queue_as :low_priority
  discard_on ::ParserError::DataNotFound

  def perform(version:, stadium_tel_code:, event_starts_on:)
    CrawlMotorRenewalService.call(version: version, stadium_tel_code: stadium_tel_code, event_starts_on: event_starts_on)
  end
end
