class Api::V1::AnnualReportUploadsController < ApplicationController
  before_action :authenticate_user!

  def index
    epix_user_id = current_epix_user && current_epix_user.id
    @annual_report_uploads =
      Trade::AnnualReportUpload.created_by(epix_user_id)
    @submitted_uploads = @annual_report_uploads.submitted.
      paginate(page: params[:submitted_uploads], per_page: 10).map do |aru|
        AnnualReportUploadSerializer.new(aru)
    end

    @in_progress_uploads = @annual_report_uploads.in_progress.
      paginate(page: params[:in_progress_uploads], per_page: 10).map do |aru|
        AnnualReportUploadSerializer.new(aru)
    end

    render json: {
      annual_report_uploads: {
        submitted_uploads: @submitted_uploads,
        in_progress_uploads: @in_progress_uploads
      }
    }
  end

  private

  def authenticate_user!
    render "unauthorised" unless (current_epix_user || current_sapi_user).present?
  end
end
