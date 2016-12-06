class ShipmentsController < ApplicationController
  before_action :authorise_edit, only: [:edit, :update, :destroy]

  def index
    @annual_report_upload =
      Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    @validation_error = Trade::ValidationError.find_by_id(params[:validation_error_id])
    shipments = @annual_report_upload.sandbox.shipments(@validation_error)
    per_page = Trade::SandboxTemplate.per_page
    @total_pages = (shipments.count / per_page.to_f).ceil
  end

  def edit
    @annual_report_upload =
      Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    @shipment = Trade::SandboxTemplate.find(params[:id])
  end

  def update
    @annual_report_upload =
      Trade::AnnualReportUpload.find(params[:annual_report_upload_id])
    @shipment = Trade::SandboxTemplate.find(params[:id])
    if @shipment.update_attributes(shipment_params)
      flash[:notice] = t('shipment_updated')
    else
      flash[:error] = t('shipment_not_updated')
    end
    redirect_to annual_report_upload_shipments_path(@annual_report_upload)
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

  private

  def shipment_params
    params.require(:trade_sandbox_template).
      permit(:appendix, :taxon_name, :term_code, :quantity,
             :unit_code, :trading_partner, :country_of_origin,
             :import_permit, :export_permit, :origin_permit,
             :purpose_code, :source_code, :year)
  end
end
