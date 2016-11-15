class AnnualReportUploadsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    epix_user_id = current_epix_user && current_epix_user.id
    per_page = Sapi::Trade::AnnualReportUpload.per_page

    @annual_report_uploads =
      Sapi::Trade::AnnualReportUpload.created_by(epix_user_id)

    submitted_uploads = @annual_report_uploads.submitted

    in_progress_uploads = @annual_report_uploads.in_progress

    @submitted_pages = (submitted_uploads.count / per_page.to_f).ceil
    @in_progress_pages = (in_progress_uploads.count / per_page.to_f).ceil

    @countries = Sapi::GeoEntity.includes(:geo_entity_type).where('geo_entity_types.name' => 'COUNTRY').order(:name_en)

    @sandbox_enabled = current_epix_user &&
      current_epix_user.organisation.trade_error_correction_in_sandbox_enabled
  end

  private

  def authenticate_user!
    render "unauthorised" unless (current_epix_user || current_sapi_user).present?
  end
end
