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

  # TODO get shipments by Annual Report Upload
  def changes_history
    shipments = Trade::SandboxTemplate.all.joins(
      "JOIN versions v ON v.item_id = trade_sandbox_template.id"
    ).uniq
    @shipments = shipments.paginate(
      page: params[:shipments]).map do |shipment|
        SandboxShipmentChangesSerializer.new(shipment)
      end

    render json: {
      shipments: @shipments
    }
  end

  private

  def authenticate_user!
    render "unauthorised" unless (current_epix_user || current_sapi_user).present?
  end
end
