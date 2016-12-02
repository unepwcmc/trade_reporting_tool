class AnnualReportUploadsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorise_destroy, only: [:destroy]
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
    @annual_report_upload = Trade::AnnualReportUpload.find(params[:id])
    ar_klass = @annual_report_upload.sandbox.ar_klass
    shipments = ar_klass.joins(
      "JOIN versions v on v.item_id = #{ar_klass.table_name}.id"
    ).uniq
    per_page = Trade::SandboxTemplate.per_page
    @total_pages = (shipments.count / per_page.to_f).ceil
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

  private

  def authenticate_user!
    render "unauthorised" unless (current_epix_user || current_sapi_user).present?
  end

  def authorise_destroy
    aru = Trade::AnnualReportUpload.find(params[:id])
    creator = aru.creator
    authorised = true
    if creator.is_a?(Epix::User)
      if current_user.is_a?(Sapi::User)
        flash[:alert] = t('aru_not_deleted')
        redirect_to annual_report_uploads_path and return true
      end
      authorised = (current_user.id == creator.id ||
        (current_user.organisation.id == creator.organisation.id && current_user.is_admin))
    else
      authorised = current_user.is_a?(Sapi::User) && current_user.role == Sapi::User::MANAGER
    end
    if !authorised || aru.submitted_at.present?
      flash[:alert] = t('aru_not_deleted')
      redirect_to annual_report_uploads_path
    end
  end

end
