require "spec_helper"

module Sidekiq
  describe Client do
    before do
      Sidekiq.server_middleware { |chain| chain.add Sidekiq::Asap::Middleware }
    end

    let(:jobs){Sidekiq.redis { |r| r.lrange "queue:api_calls", 0, -1 }}

    it "pushes asap jobs bottom of non-asap list" do
      Sidekiq::Client.push('queue' => 'api_calls',      'class' => RegularWorker, 'args' => ['normal'])
      Sidekiq::Client.push('queue' => 'asap_api_calls', 'class' => RegularWorker, 'args' => ['urgent'])

      expect(Sidekiq.load_json(jobs.last)).to include("queue" => 'api_calls', 'args' => ['urgent'], 'asap' => true)
    end

    it "pushes non-asap jobs to top of non-asap list" do
      Sidekiq::Client.push('queue' => 'api_calls', 'class' => RegularWorker, 'args' => ['normal'])
      Sidekiq::Client.push('queue' => 'api_calls', 'class' => RegularWorker, 'args' => ['urgent'])

      expect(Sidekiq.load_json(jobs.first)).to include("queue" => 'api_calls', 'args' => ['urgent'])
    end
  end
end
