require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.secrets.redis['url'] }
  Rails.logger = Sidekiq::Logging.logger
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.secrets.redis['url'] }
end
