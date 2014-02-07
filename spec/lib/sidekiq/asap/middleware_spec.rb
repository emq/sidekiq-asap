require "spec_helper"

module Sidekiq
  module Asap
    describe Middleware do

      def call_worker
        Sidekiq::Asap::Middleware.new.call(RegularWorker, msg, queue) do
          # worker stuff happening
        end
      end

      let(:msg){ {'class' => 'RandomStuff', 'args' => ['custom_argument'], 'retry' => false } }

      describe "when queue is asap" do
        let(:queue){ "asap_api_calls" }
        before { call_worker }

        it "modifies arguments and queue" do
          expect(msg['asap']).to be(true)
          expect(queue).to eq 'api_calls'
        end
      end

      describe "when queue is not asap" do
        let(:queue){ 'awesome_api_calls' }
        before { call_worker }

        it "does nothing" do
          expect(msg['asap']).to be_nil
          expect(queue).to eq 'awesome_api_calls'
        end
      end
    end
  end
end
