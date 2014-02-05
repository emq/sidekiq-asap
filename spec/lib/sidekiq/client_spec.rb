require "spec_helper"

module Sidekiq
  describe Client do
    before do
      Sidekiq.server_middleware { |chain| chain.add Sidekiq::Asap::Middleware }
    end

    it "pushes asap jobs bottom of non-asap list" do
      2.times { Sidekiq::Client.push('queue' => 'api_calls', 'class' => RegularWorker, 'args' => ['normal']) }
      Sidekiq::Client.push('queue' => 'asap_api_calls', 'class' => RegularWorker, 'args' => ['urgent'])

      jobs = Sidekiq.redis { |r| r.lrange "queue:api_calls", 0, -1 }
      expect(Sidekiq.load_json(jobs[2])).to include("queue" => 'api_calls', 'args' => ['urgent'], 'asap' => true)
    end
  end
end
