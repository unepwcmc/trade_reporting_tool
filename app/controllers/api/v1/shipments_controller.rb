class Api::V1::ShipmentsController < ApplicationController

  def index
    @annual_report_upload =
      Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    @validation_error = Trade::ValidationError.find_by_id(params[:validation_error_id])
    @shipments = @annual_report_upload.sandbox.shipments(@validation_error).paginate(
      page: params[:shipments]).map do |shipment|
        SandboxShipmentSerializer.new(shipment)
      end

    render json: {
      shipments: @shipments
    }
  end

end
