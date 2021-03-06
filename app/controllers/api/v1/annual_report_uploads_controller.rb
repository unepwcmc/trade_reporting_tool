class Api::V1::AnnualReportUploadsController < ApplicationController

  def index
    user_id = current_user && current_user.id
    user_type = current_user && current_user.is_a?(Epix::User) ? 'epix' : 'sapi'
    @annual_report_uploads =
      Trade::AnnualReportUpload.created_by(user_id, user_type).
      order(created_at: :desc)
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

  def changes_history
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    ar_klass = @annual_report_upload.sandbox.ar_klass
    shipments = ar_klass.joins(
      "JOIN versions v on v.item_id = #{ar_klass.table_name}.id"
    ).uniq
    @shipments = shipments.paginate(
      page: params[:shipments]).map do |shipment|
        SandboxShipmentChangesSerializer.new(shipment)
      end

    ar_klass.destroyed.map(&:reify).map do |shipment|
      @shipments << SandboxShipmentChangesSerializer.new(shipment)
    end

    render json: {
      shipments: @shipments
    }
  end

  def changes_history_download
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    shipments = @annual_report_upload.shipments_with_versions(params[:shipments])

    @shipments = shipments.map do |shipment|
      SandboxShipmentChangesSerializer.new(shipment)
    end

    render json: {
      shipments: @shipments
    }
  end

end
