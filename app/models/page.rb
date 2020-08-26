require 'open-uri'

class Page
  BASE_URL = Rails.application.config.x.official_website_proxy.base_url
  USE_VERSION = Rails.application.config.x.official_website_proxy.latest_official_website_version

  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :version, :integer, default: USE_VERSION
  attribute :no_cache, :boolean, default: false

  def file
    URI.open("#{BASE_URL}/file?#{query}", **headers)
  end

  def origin_redirection_url
    "#{BASE_URL}/redirection?#{query}"
  end

  private

    def query
      params.merge({
        version: version,
        page_type: self.class.name.underscore,
      }).to_query
    end

    def params
      raise NotImplementedError
    end

    def headers
      h = {}
      h['Cache-Control'] = 'no-cache' if no_cache
      h
    end
end