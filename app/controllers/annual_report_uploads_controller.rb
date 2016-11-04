class AnnualReportUploadsController < ApplicationController
  respond_to :json

  def index
    epix_user_id = current_epix_user && current_epix_user.id
    @annual_report_uploads =
      Sapi::Trade::AnnualReportUpload.created_by(epix_user_id)
    @submitted_uploads = @annual_report_uploads.submitted.map do |aru|
        AnnualReportUploadSerializer.new(aru)
    end

    @in_progress_uploads = @annual_report_uploads.in_progress.map do |aru|
        AnnualReportUploadSerializer.new(aru)
    end
  end
end
