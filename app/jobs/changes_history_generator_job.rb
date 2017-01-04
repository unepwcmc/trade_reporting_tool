require 'aws-sdk'
class ChangesHistoryGeneratorJob < ApplicationJob
  queue_as :default

  def perform(aru_id, user, aws=false)
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      message = "CITES Report #{aru_id} not found"
      Rails.logger.warn message
      Appsignal.add_exception(e) if defined? Appsignal
      NotificationMailer.changelog_failed(user, aru).deliver
    end

    tempfile = ChangelogCsvGenerator.call(aru, user)

    if aws
      s3 = Aws::S3::Resource.new
      filename = "trade/annual_report_upload/#{aru.id}/changelog.csv"
      obj = s3.bucket('annualreportuploadschangelogs').object(filename)
      obj.upload_file(tempfile.path)
      tempfile.delete

      # remove sandbox table
      aru.sandbox.destroy

    else
      NotificationMailer.changelog(user, aru, tempfile).deliver
    end
  end
end
