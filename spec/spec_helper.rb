require "rspec"
require "sidekiq"

require_relative "../lib/sidekiq-asap"
Sidekiq.logger.level = Logger::ERROR

class RegularWorker
  include ::Sidekiq::Worker
end

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq.redis = { url: "redis://localhost/15", namespace: "sideki-asap" }
    Sidekiq.redis { |c| c.flushdb }
  end

  config.order = 'random'
end
