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
                SubmittedData: Api::V1::CitesReport,
                ForceSubmitWithWarnings: :boolean
              },
              return: :cites_report_result

  def submit_cites_report
    @aru = Sapi::Trade::AnnualReportUpload.new
    @aru.trading_country_id = @sapi_country.id
    @aru.epix_created_by_id = @user.id
    @aru.epix_created_at = Time.now
    @aru.epix_updated_by_id = @aru.epix_created_by_id
    @aru.epix_updated_at = @aru.epix_created_at
    if @aru.save
      # TODO: store data in sandbox
      render xml: {'test' => 'passed'}
    else
      render_soap_error "Invalid request: #{@aru.errors.map{|p,m| "#{p}: #{m}" }.join(' ')}"
    end
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
