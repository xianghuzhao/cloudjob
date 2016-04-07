require 'sidetiq'

require 'mongoid'

ROOT_PATH = File.expand_path('..', __FILE__)

Mongoid.load! "#{ROOT_PATH}/config/mongoid.yml", :development


# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://192.168.32.12:6379', size: 1 }
end

# Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://192.168.32.12:6379' }
end

require_relative 'app/workers/scheduler'
require_relative 'app/workers/host_manager'
