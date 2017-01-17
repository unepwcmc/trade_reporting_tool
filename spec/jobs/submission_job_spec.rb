require "rails_helper"

RSpec.describe SubmissionJob, type: :job do
  include ActiveJob::TestHelper

  let(:aru){ FactoryGirl.create(:annual_report_upload) }
  let(:submitter) { FactoryGirl.create(:epix_user) }
  subject(:job) { described_class.perform_later(aru.id, submitter.id, 'Epix') }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(SubmissionJob.new.queue_name).to eq('default')
  end
end
