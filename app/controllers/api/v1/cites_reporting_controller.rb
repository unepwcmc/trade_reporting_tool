class Api::V1::CitesReportingController < ApplicationController
  soap_service namespace: 'urn:CitesReporting/v1/', wsdl_style: 'document'

  soap_action 'submit_cites_report',
              args: {
                cites_report: Api::V1::CitesReport
              },
              return: :cites_report_result
  def submit_cites_report
    render xml: {'test' => 'passed'}.to_xml
  end
end
