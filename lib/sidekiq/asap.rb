require "sidekiq/asap/version"
require "sidekiq/client"

module Sidekiq
  class Client

    private

    def atomic_push(conn, payloads)
      if payloads.first['at']
        conn.zadd('schedule'.freeze, payloads.map do |hash|
          at = hash.delete('at'.freeze).to_s
          [at, Sidekiq.dump_json(hash)]
        end)
      else
        q = payloads.first['queue']
        method = :lpush

        if q =~ /^asap_/
          method = :rpush
          q = q.gsub("asap_", "")
        end

        now = Time.now.to_f
        to_push = payloads.map do |entry|
          entry['enqueued_at'.freeze] = now
          Sidekiq.dump_json(entry)
        end
        conn.sadd('queues'.freeze, q)
        conn.public_send(method, "queue:#{q}", to_push)
      end
    end
  end
end
