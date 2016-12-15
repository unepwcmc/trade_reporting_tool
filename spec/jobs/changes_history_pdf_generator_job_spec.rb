require "rails_helper"

RSpec.describe ChangesHistoryPdfGeneratorJob, type: :job do
  include ActiveJob::TestHelper

  let(:aru){ FactoryGirl.create(:annual_report_upload) }
  subject(:job) { described_class.perform_later(aru.id, '', '', '', '') }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(CitesReportValidationJob.new.queue_name).to eq('default')
  end
end
