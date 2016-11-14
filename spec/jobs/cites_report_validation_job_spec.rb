require "rails_helper"

RSpec.describe CitesReportValidationJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    CitesReportValidationJob.perform_later
    expect(CitesReportValidationJob).to have_been_enqueued
  end
end