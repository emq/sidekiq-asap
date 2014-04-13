require "spec_helper"

module Sidekiq
  describe Client do
    let(:jobs){Sidekiq.redis { |r| r.lrange "queue:api_calls", 0, -1 }}

    def push_asap
      Sidekiq::Client.push('queue' => 'api_calls',      'class' => RegularWorker, 'args' => ['normal'])
      Sidekiq::Client.push('queue' => 'asap_api_calls', 'class' => RegularWorker, 'args' => ['urgent'])
    end

    def push_regular
      Sidekiq::Client.push('queue' => 'api_calls', 'class' => RegularWorker, 'args' => ['normal'])
      Sidekiq::Client.push('queue' => 'api_calls', 'class' => RegularWorker, 'args' => ['urgent'])
    end

    it "pushes asap jobs bottom of non-asap list" do
      push_asap
      expect(Sidekiq.load_json(jobs.last)).to include("queue" => 'asap_api_calls', 'args' => ['urgent'])
      expect(jobs.size).to eq(2)
    end

    it "pushes non-asap jobs to top of non-asap list" do
      push_regular
      expect(Sidekiq.load_json(jobs.first)).to include("queue" => 'api_calls', 'args' => ['urgent'])
      expect(jobs.size).to eq(2)
    end
  end
end
