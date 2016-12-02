class ShipmentsController < ApplicationController
  before_action :authorise_edit, only: [:destroy]

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
    if @shipment.destroy
      flash[:notice] = t('shipment_deleted')
    else
      flash[:error] = t('shipment_not_deleted')
    end
    redirect_to annual_report_upload_shipments_path(@annual_report_upload)
  end
end
