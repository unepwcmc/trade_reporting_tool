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

    tempfile = ChangelogCsvGenerator.call(aru, user, aws)

    if aws
      begin
        s3 = Aws::S3::Resource.new
        filename = "#{Rails.env}/trade/annual_report_upload/#{aru.id}/changelog.csv"
        bucket_name = Rails.application.secrets.aws['bucket_name']
        obj = s3.bucket(bucket_name).object(filename)
        obj.upload_file(tempfile.path)
        aru.update_attributes(aws_storage_path: obj.public_url)
      rescue => e
        Rails.logger.info("Something went wrong while uploading file to S3")
        Rails.logger.info(e)
      end
    end

    NotificationMailer.changelog(user, aru, tempfile).deliver

    tempfile.delete

    # remove sandbox table
    aru.sandbox(true).destroy
  end
end
