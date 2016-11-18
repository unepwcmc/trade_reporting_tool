require "rails_helper"

RSpec.describe CitesReportValidationJob, type: :job do
  include ActiveJob::TestHelper

  let(:aru){ FactoryGirl.create(:annual_report_upload) }
  subject(:job) { described_class.perform_later(aru.id, false) }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(CitesReportValidationJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect(CitesReportValidator).to receive(:call).with(aru.id, false)
    perform_enqueued_jobs { job }
  end
end
