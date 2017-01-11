require 'zip'
class AnnualReportUploadsController < ApplicationController
  before_action :authorise_edit, only: [:destroy]
  respond_to :json

  def index
    user_id = current_user && current_user.id
    user_type = current_user && current_user.is_a?(Epix::User) ? 'epix' : 'sapi'
    per_page = Trade::AnnualReportUpload.per_page

    @annual_report_uploads =
      Trade::AnnualReportUpload.created_by(user_id, user_type)
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
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    ar_klass = @annual_report_upload.sandbox.ar_klass
    shipments = ar_klass.joins(
      "JOIN versions v on v.item_id = #{ar_klass.table_name}.id"
    ).uniq
    per_page = Trade::SandboxTemplate.per_page
    @total_pages = (shipments.count / per_page.to_f).ceil
  end

  def changes_history_download
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        ChangesHistoryGeneratorJob.perform_later(
          @annual_report_upload.id, current_user
        )
        flash[:notice] = t('aru_changelog_generation_scheduled')
        redirect_to changes_history_url(@annual_report_upload)
      end
    end
  end

  def submit
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    if @annual_report_upload.submit(current_user)
      flash[:notice] = "Annual Report Upload #{params[:id]} submitted succesfully"
    else
      flash[:error] = @annual_report_upload.errors
    end
    redirect_to annual_report_uploads_path
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
    if !aru.is_submitted? && !aru.validation_report
      render json: { error: t('download_report_disabled') }
      return
    end
    validation_report_csv_file = ValidationReportCsvGenerator.call(aru)

    changelog = aru.get_changelog("changelog_#{aru.id}-")
    zipfile = "#{Rails.root.join('tmp')}/report_#{aru.id}.zip"
    Zip::File.open(zipfile, Zip::File::CREATE) do |zipfile|
      zipfile.add('changelog.csv', changelog.path) unless File.zero?(changelog)
      zipfile.add('validation_report.csv', validation_report_csv_file.path)
    end

    data = File.read(zipfile)
    changelog.delete
    File.delete(zipfile)
    send_data data, type: 'application/zip', filename: "report_#{aru.id}.zip"
  end

end
