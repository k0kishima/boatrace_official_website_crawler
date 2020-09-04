class CrawlRacerProfileJob < ApplicationJob
  include FileReloadable
  queue_as :low_priority

  def perform(version:, racer_registration_number:)
    CrawlRacerProfileService.call(version: version, racer_registration_number: racer_registration_number, no_cache: no_cache)
  end
end
