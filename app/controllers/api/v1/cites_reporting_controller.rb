class Api::V1::CitesReportingController < ApplicationController
  soap_service namespace: 'urn:CitesReporting/v1/', wsse_auth_callback: -> (email, password) {
    user = Epix::User.includes(:organisation).
      where(email: email, 'organisations.role' => Epix::Organisation::CITES_MA).
      first
    return user.present? && user.valid_password?(password)
  }

  before_action :load_user_and_organisation, except: :_generate_wsdl

  rescue_from NoMethodError, with: :handle_no_method_error

  soap_action :submit_cites_report,
              as: 'SubmitCitesReportRequest',
              args: {
                TypeOfReport: :string,
                SubmittedData: Api::V1::CitesReport,
                ForceSubmitWithWarnings: :boolean
              },
              return: {CITESReportResult: Api::V1::CITESReportResult}

  def submit_cites_report
    @cites_report = CitesReportFromWS.new(
      @sapi_country,
      @user,
      {
        type_of_report: params[:TypeOfReport],
        submitted_data: params[:SubmittedData],
        force_submit: params[:ForceSubmitWithWarnings]
      }
    )
    @cites_report.save
    result = Api::V1::CITESReportResultBuilder.new(@cites_report.aru).result
    render xml: result
  end

  soap_action :get_cites_report_status,
              as: 'GetCitesReportStatusRequest',
              args: {
                CITESReportId: :integer
              },
              return: {CITESReportResult: Api::V1::CITESReportResult}

  def get_cites_report_status
    @aru = Trade::AnnualReportUpload.find(params[:CITESReportId])
    result = Api::V1::CITESReportResultBuilder.new(@aru).result
    render xml: result
  end

  private

  # this is where we get when XML was completely invalid
  # e.g. closing element missing
  def handle_no_method_error(exception)
    log_error(exception)
    render_soap_error "Invalid request"
  end

  def log_error(exception)
    if Rails.env.production? || Rails.env.staging?
      # TODO: Appsignal.add_exception(exception) if defined? Appsignal
    else
      Rails.logger.error exception.message
      Rails.logger.error exception.backtrace.join("\n")
    end
  end

  def load_user_and_organisation
    wsse_token = request.env['WSSE_TOKEN']
    user_email = wsse_token.values_at(:username, :Username).compact.first
    @user = Epix::User.find_by_email(user_email)
    @organisation = @user.organisation
    @sapi_country = Sapi::GeoEntity.find_by_iso_code2(@organisation.country.iso_code2)
  end

end
