redis_config = {
  url: Rails.application.config.x.redis_url,
  namespace: "#{Rails.application.class.module_parent_name.underscore.downcase}:#{Rails.env}",
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
