class AnnualReportUploadsController < ApplicationController
  before_action :authorise_edit, only: [:destroy]
  before_action :fetch_shipments, only: [:changes_history, :changes_history_pdf]
  respond_to :json

  def index
    epix_user_id = current_epix_user && current_epix_user.id
    per_page = Trade::AnnualReportUpload.per_page

    @annual_report_uploads =
      Trade::AnnualReportUpload.created_by(epix_user_id)
    @submitted_uploads = @annual_report_uploads.submitted.map do |aru|
        AnnualReportUploadSerializer.new(aru)
    end

    submitted_uploads = @annual_report_uploads.submitted

    in_progress_uploads = @annual_report_uploads.in_progress

    @submitted_pages = (submitted_uploads.count / per_page.to_f).ceil
    @in_progress_pages = (in_progress_uploads.count / per_page.to_f).ceil

    @countries = Sapi::GeoEntity.includes(:geo_entity_type).where('geo_entity_types.name' => 'COUNTRY').order(:name_en)

    @sandbox_enabled = current_epix_user &&
      current_epix_user.organisation.trade_error_correction_in_sandbox_enabled
  end

  def show
    annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    annual_report_upload.process_validation_rules
    @annual_report_upload =
      ShowAnnualReportUploadSerializer.new(annual_report_upload)
  end

  def changes_history
  end

  def changes_history_pdf
    cookie = cookies.to_h['_trade_reporting_tool_session']
    respond_to do |format|
      format.html
      format.pdf do
        rasterizer = Rails.root.join("vendor/assets/javascripts/rasterize.js")
        url = changes_history_pdf_url
        dest_pdf = Rails.root.join("tmp/changes_history.pdf").to_s
        `phantomjs #{rasterizer} '#{url}' #{dest_pdf} #{cookie} #{request.domain}`
        send_file dest_pdf, type: 'application/pdf'
      end
    end
  end

  def destroy
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    if @annual_report_upload.destroy_with_sandbox
      flash[:notice] = t('aru_deleted')
    else
      flash[:alert] = t('aru_not_deleted')
    end
    redirect_to annual_report_uploads_path
  end

  def download_error_report
    aru = Trade::AnnualReportUpload.find(params[:id])
    validation_report_csv_file = ValidationReportCsvGenerator.call(aru)
    data = File.read(validation_report_csv_file)

    send_data data, type: 'text/csv', filename: "validation_report_#{aru.id}.csv"
  end

  def fetch_shipments
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    ar_klass = @annual_report_upload.sandbox.ar_klass
    shipments = ar_klass.joins(
      "JOIN versions v on v.item_id = #{ar_klass.table_name}.id"
    ).uniq
    per_page = Trade::SandboxTemplate.per_page
    @total_pages = (shipments.count / per_page.to_f).ceil
  end

end
