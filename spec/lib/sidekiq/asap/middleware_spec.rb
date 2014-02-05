require "spec_helper"

module Sidekiq
  module Asap
    describe Middleware do
      it "modifies arguments and queue when queue is asap_" do
        msg = {'class' => 'RandomStuff', 'args' => ['custom_argument'], 'retry' => false }
        queue = 'asap_api_calls'

        Sidekiq::Asap::Middleware.new.call(RegularWorker, msg, queue) do
          # worker stuff
        end

        expect(msg['asap']).to be(true)
        expect(queue).to eq 'api_calls'
      end

      it "does nothing if queue is not asap" do
        msg = {'class' => 'RandomStuff', 'args' => ['custom_argument'], 'retry' => false }
        queue = 'awesome_api_calls'

        Sidekiq::Asap::Middleware.new.call(RegularWorker, msg, queue) do
          # worker stuff
        end

        expect(msg['asap']).to be_nil
        expect(queue).to eq 'awesome_api_calls'
      end
    end
  end
end
