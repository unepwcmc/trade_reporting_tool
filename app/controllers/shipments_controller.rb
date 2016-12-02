class ShipmentsController < ApplicationController
  def index
    @annual_report_upload =
      Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    shipments = @annual_report_upload.sandbox.shipments
    per_page = Trade::SandboxTemplate.per_page
    @total_pages = (shipments.count / per_page.to_f).ceil
  end

  def destroy
    @annual_report_upload =
      Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    @shipment = @annual_report_upload.sandbox.ar_klass.find(params[:id])
    @shipment.destroy
    redirect_to annual_report_upload_shipments_path(@annual_report_upload)
  end
end
