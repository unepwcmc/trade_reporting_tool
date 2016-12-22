require "rails_helper"

RSpec.describe DownloadsCacheCleanupJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later('shipments') }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'should invoke clear shipments method' do
    expect(DownloadsCache).to receive('clear_shipments')
    described_class.perform_now('shipments')
  end
end

