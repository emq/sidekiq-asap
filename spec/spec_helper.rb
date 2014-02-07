require "rspec"
require "celluloid"
require "sidekiq"
require "sidekiq/processor"

require_relative "../lib/sidekiq-asap"

Sidekiq.logger.level = Logger::ERROR
REDIS = Sidekiq::RedisConnection.create(url: "redis://localhost/15", namespace: "sideki-asap")

class RegularWorker
  include ::Sidekiq::Worker
end

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq.redis = REDIS
    Sidekiq.redis { |c| c.flushdb }
  end

  config.order = 'random'
end
