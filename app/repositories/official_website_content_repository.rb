require 'open-uri'

# Hack
#
# これもFundamentalDataRepository と同様
# サービスの単位でクラスは粒度大きすぎるので
# RacerProfileFileRepository.fetch みたいにすべきだった
#
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

    def event_schedule_file(version: USE_VERSION, year: , month: )
      query = {
          version: version,
          page_type: :event_schedule_page,
          year: year,
          month: month,
      }.to_query
      URI.open("#{BASE_URL}/file?#{query}")
    end

    def event_holding_file(version: USE_VERSION, date: )
      query = {
          version: version,
          page_type: :event_holdings_page,
          date: date,
      }.to_query
      URI.open("#{BASE_URL}/file?#{query}")
    end

    def event_entry_file(version: USE_VERSION, stadium_tel_code: , event_starts_on: )
      query = {
          version: version,
          page_type: :event_entries_page,
          stadium_tel_code: stadium_tel_code,
          event_starts_on: event_starts_on,
      }.to_query
      URI.open("#{BASE_URL}/file?#{query}")
    end

    def race_information_file(version: USE_VERSION, stadium_tel_code: , date: , race_number:)
      query = {
          version: version,
          page_type: :race_information_page,
          stadium_tel_code: stadium_tel_code,
          race_opened_on: date,
          race_number: race_number,
      }.to_query
      URI.open("#{BASE_URL}/file?#{query}")
    end

    def race_exhibition_information_file(version: USE_VERSION, stadium_tel_code: , date: , race_number:)
      query = {
          version: version,
          page_type: :race_exhibition_information_page,
          stadium_tel_code: stadium_tel_code,
          race_opened_on: date,
          race_number: race_number,
      }.to_query
      URI.open("#{BASE_URL}/file?#{query}")
    end

    def race_result_file(version: USE_VERSION, stadium_tel_code: , date: , race_number:)
      query = {
          version: version,
          page_type: :race_result_page,
          stadium_tel_code: stadium_tel_code,
          race_opened_on: date,
          race_number: race_number,
      }.to_query
      URI.open("#{BASE_URL}/file?#{query}")
    end

    def race_odds_file(version: USE_VERSION, stadium_tel_code: , date: , race_number:)
      query = {
          version: version,
          page_type: :race_odds_page,
          stadium_tel_code: stadium_tel_code,
          race_opened_on: date,
          race_number: race_number,
      }.to_query
      URI.open("#{BASE_URL}/file?#{query}")
    end
  end
end
