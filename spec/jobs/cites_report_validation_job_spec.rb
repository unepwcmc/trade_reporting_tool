require "rails_helper"

RSpec.describe CitesReportValidationJob, type: :job do
  include ActiveJob::TestHelper

  let(:aru){ FactoryGirl.create(:epix_upload) }
  let(:user) { FactoryGirl.create(:epix_user) }
  subject(:job) { described_class.perform_later(aru.id, user) }
  subject(:job_without_email) { described_class.perform_later(aru.id, user, false) }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(CitesReportValidationJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect(CitesReportValidator).to receive(:call).with(aru.id, user, true)
    perform_enqueued_jobs { job }
  end

  context "sending email" do
    let(:aru) {
      FactoryGirl.create(:epix_upload)
    }
    before(:each) do
      allow_any_instance_of(Trade::AnnualReportUpload).to(
        receive_message_chain(:persisted_validation_errors, :primary).and_return([])
      )
      allow_any_instance_of(Trade::AnnualReportUpload).to(
        receive_message_chain(:persisted_validation_errors, :secondary).and_return([])
      )
      allow_any_instance_of(Trade::AnnualReportUpload).to(
        receive(:submit).with(user)
      )
      allow_any_instance_of(Trade::Sandbox).to(
        receive(:copy_from_sandbox_to_shipments).and_return(true)
      )
      allow(CitesReportValidator).to(
        receive(:generate_validation_report).and_return(
          {'0' => {'data' => {}, 'errors' => []}}
        )
      )
    end
    it 'sends an email' do
      expect { perform_enqueued_jobs { job } }.to(
        change { ActionMailer::Base.deliveries.count }.by(1)
      )
    end
    it 'does not send any email' do
      expect { perform_enqueued_jobs { job_without_email } }.to(
        change { ActionMailer::Base.deliveries.count }.by(0)
      )
    end
  end
end
