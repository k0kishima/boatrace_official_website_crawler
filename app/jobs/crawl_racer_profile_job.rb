class CrawlRacerProfileJob < ApplicationJob
  queue_as :low_priority

  def perform(version:, racer_registration_number:)
    CrawlRacerProfileService.call(version: version, racer_registration_number: racer_registration_number)
  end
end
