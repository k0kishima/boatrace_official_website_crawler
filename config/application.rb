require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.time_zone = 'Asia/Tokyo'

    config.active_job.queue_adapter = :sidekiq
    config.x.redis_url = ENV.fetch('SIDEKIQ_REDIS_URL') { 'redis://127.0.0.1:6379' }

    config.x.fundamental_data_repository.api_base_url = ENV.fetch('FUNDAMENTAL_DATA_API_BASE_URL') { 'http://fundamental-data-server:3000' }
    config.x.fundamental_data_repository.application_token = ENV.fetch('FUNDAMENTAL_DATA_API_APPLICATION_TOKEN') { '*****' }

    config.x.official_website_proxy.base_url = ENV.fetch('OFFICIAL_WEBSITE_PROXY_BASE_URL') { 'http://official-website-proxy:5000' }
    config.x.official_website_proxy.official_website_version = ENV.fetch('OFFICIAL_WEBSITE_VERSION') { 1707 }
  end
end
