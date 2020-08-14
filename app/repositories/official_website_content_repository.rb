require 'open-uri'

module OfficialWebsiteContentRepository
  BASE_URL = Rails.application.config.x.official_website_proxy.base_url
  USE_VERSION = Rails.application.config.x.official_website_proxy.official_website_version

  class << self
    def racer_profile_file(version: USE_VERSION, racer_registration_number:)
      query = {
          version: version,
          page_type: :racer_profile_page,
          registration_number: racer_registration_number,
      }.to_query
      URI.open("#{BASE_URL}/file?#{query}")
    end
  end
end
