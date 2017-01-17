class SubmissionJob < ApplicationJob
  queue_as :default

  def perform(aru_id, submitter_id, submitter_type)
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      Rails.logger.warn "CITES Report #{aru_id} not found"
      Appsignal.add_exception(e) if defined? Appsignal
      NotificationMailer.changelog_failed(user, aru).deliver
    end
    submitter = if submitter_type == 'Epix'
                  Epix::User.find(submitter_id)
                else
                  Sapi::User.find(submitter_id)
                end

    duplicates = aru.sandbox.check_for_duplicates_in_shipments
    if duplicates.present?
      tempfile = ChangelogCsvGenerator.call(aru, submitter, true, duplicates)
      NotificationMailer.duplicates(submitter, aru, tempfile).deliver
      return false
    end

    return false unless aru.sandbox.copy_from_sandbox_to_shipments(submitter)

    tempfile = ChangelogCsvGenerator.call(aru, submitter)

    upload_on_S3(aru, tempfile)

    records_submitted = aru.sandbox.moved_rows_cnt

    # clear downloads cache
    DownloadsCache.send(:clear_shipments)

    aru.sandbox.destroy

    # flag as submitted
    if submitter_type == 'Epix'
      aru.update_attributes({
        epix_submitted_at: DateTime.now,
        epix_submitted_by_id: submitter.id,
        number_of_records_submitted: records_submitted
      })
    else
      aru.update_attributes({
        submitted_at: DateTime.now,
        submitted_by_id: submitter.id,
        number_of_records_submitted: records_submitted
      })
    end

    NotificationMailer.changelog(submitter, aru, tempfile).deliver

    tempfile.delete
  end

  private

  def upload_on_S3(aru, tempfile)
    begin
      s3 = Aws::S3::Resource.new
      filename = "#{Rails.env}/trade/annual_report_upload/#{aru.id}/changelog.csv"
      bucket_name = Rails.application.secrets.aws['bucket_name']
      obj = s3.bucket(bucket_name).object(filename)
      obj.upload_file(tempfile.path)

      aru.update_attributes(aws_storage_path: obj.public_url)
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.warn "Something went wrong while uploading #{aru.id} to S3"
      Appsignal.add_exception(e) if defined? Appsignal
    end
  end

end
