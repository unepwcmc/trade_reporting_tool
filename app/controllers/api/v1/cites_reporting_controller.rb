class Api::V1::CitesReportingController < ApplicationController
  soap_service namespace: 'urn:CitesReporting/v1/'

  rescue_from NoMethodError, with: :handle_no_method_error

  soap_action :submit_cites_report,
              as: 'SubmitCitesReportRequest',
              args: {
                SubmittedData: Api::V1::CitesReport,
                ForceSubmitWithWarnings: :boolean
              },
              return: :cites_report_result

  def submit_cites_report
    # TODO: do it
    render xml: {'test' => 'passed'}
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

end
