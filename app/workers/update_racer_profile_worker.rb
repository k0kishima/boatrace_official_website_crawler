class UpdateRacerProfileWorker
  include Shoryuken::Worker

  shoryuken_options queue: ENV['UPDATE_RACER_PROFILE_QUEUE_NAME'], auto_delete: true, body_parser: :json
  OFFICIAL_WEB_SITE_VERSION = Rails.application.config.x.official_website_proxy.latest_official_website_version

  def perform(_, body)
    CrawlRacerProfileJob.perform_later(version: OFFICIAL_WEB_SITE_VERSION,
                                       racer_registration_number: body['racer_registration_number'])
    Rails.logger.info('a racer profile had been updated by instruction via queue')
  end
end