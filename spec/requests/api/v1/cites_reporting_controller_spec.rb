require "rails_helper"

# idea for this way of testing washout controllers:
# http://blog.johnsonch.com/2013/04/18/rails-3-soap-and-testing-oh-my/

RSpec.describe Api::V1::CitesReportingController do
  HTTPI.adapter = :rack
  HTTPI::Adapter::Rack.mount 'application', TradeReportingTool::Application

  it 'can submit a CITES report' do
    application_base = "http://application"
    client = Savon::Client.new({wsdl: application_base + api_v1_cites_reporting_wsdl_path })
    response = client.call(:submit_cites_report)
    xml = Nokogiri::XML(response.to_xml)
    expect(xml.at('//test')).to be_present
  end
end
