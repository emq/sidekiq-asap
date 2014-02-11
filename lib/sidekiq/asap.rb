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
          method = :lpush

          if q =~ /^asap_/
            method = :rpush
            q = q.gsub("asap_", "")
          end

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
