require "sidekiq/asap/version"
require "sidekiq/asap/middleware"
require "sidekiq/client"

module Sidekiq
  class Client

    private

    # Ugly monkey patch
    def raw_push(payloads)
      pushed = false
      Sidekiq.redis do |conn|
        if payloads.first['at']
          pushed = conn.zadd('schedule', payloads.map do |hash|
            at = hash.delete('at').to_s
            [at, Sidekiq.dump_json(hash)]
          end)
        else
          q = payloads.first['queue']
          method = payloads.first['asap'] ? :rpush : :lpush
          to_push = payloads.map { |entry| Sidekiq.dump_json(entry) }
          _, pushed = conn.multi do
            conn.sadd('queues', q)
            conn.send(method, "queue:#{q}", to_push)
          end
        end
      end
      pushed
    end
  end

  module Asap
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Asap::Middleware
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Asap::Middleware
  end
end
