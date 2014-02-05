module Sidekiq
  module Asap
    class Middleware
      def call(worker_class, msg, queue)
        if queue =~ /^asap_/
          queue.gsub!("asap_","")
          msg["asap"] = true
        end

        yield
      end
    end
  end
end
