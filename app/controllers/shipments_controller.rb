class ShipmentsController < ApplicationController
  def index
    @annual_report_upload =
      Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    shipments = @annual_report_upload.sandbox.shipments
    per_page = Trade::SandboxTemplate.per_page
    @total_pages = (shipments.count / per_page.to_f).ceil
  end

  def destroy
    @shipment = Trade::SandboxTemplate.find(params[:id])
    @shipment.destroy
  end
end
