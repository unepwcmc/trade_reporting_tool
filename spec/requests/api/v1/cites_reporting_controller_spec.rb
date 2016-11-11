require "rails_helper"

# idea for this way of testing washout controllers:
# http://blog.johnsonch.com/2013/04/18/rails-3-soap-and-testing-oh-my/

RSpec.describe Api::V1::CitesReportingController do
  HTTPI.adapter = :rack
  HTTPI::Adapter::Rack.mount 'application', TradeReportingTool::Application

  let(:unauthorised_wsse_auth){ ['user@email.com', 'mypassword'] }
  let(:authorised_wsse_auth){ ['ma@email.com', 'mypassword'] }
  let!(:epix_user){
    FactoryGirl.create(:epix_user,
      email: unauthorised_wsse_auth.first,
      password: unauthorised_wsse_auth.last,
      password_confirmation: unauthorised_wsse_auth.last
    )
  }
  let(:sapi_poland){ FactoryGirl.create(:geo_entity, iso_code2: 'PL') }
  let(:epix_poland){ FactoryGirl.create(:country, iso_code2: sapi_poland.iso_code2) }
  let(:cites_ma){
    FactoryGirl.create(
      :organisation,
      role: Epix::Organisation::CITES_MA,
      country: epix_poland
    )
  }
  let!(:epix_ma_user){
    FactoryGirl.create(
      :epix_user,
      organisation: cites_ma,
      email: authorised_wsse_auth.first,
      password: authorised_wsse_auth.last,
      password_confirmation: authorised_wsse_auth.last
    )
  }

  it 'cannot submit a CITES report if not authorised' do
    application_base = "http://application"
    client = Savon::Client.new({
      wsdl: application_base + api_v1_cites_reporting_wsdl_path,
      wsse_auth: unauthorised_wsse_auth,
      log: true,
      logger: Rails.logger
    })
    expect {
      client.call(:submit_cites_report)
    }.to raise_error(Savon::SOAPFault)
  end

  it 'cannot submit a CITES report if XML invalid' do
    application_base = "http://application"
    client = Savon::Client.new({
      wsdl: application_base + api_v1_cites_reporting_wsdl_path,
      wsse_auth: authorised_wsse_auth,
      log: true,
      logger: Rails.logger
    })
    expect {
      client.call(:submit_cites_report)
    }.to raise_error(Savon::SOAPFault)
  end

  it 'can submit a CITES report if authorised' do
    application_base = "http://application"
    client = Savon::Client.new({
      wsdl: application_base + api_v1_cites_reporting_wsdl_path,
      wsse_auth: authorised_wsse_auth,
      log: true,
      logger: Rails.logger
    })
    response = client.call(:submit_cites_report, message: {
      'TypeOfReport' => 'E',
      'SubmittedData' => ['CITESReport' => {'CITESReportRow' => {}}],
      'ForceSubmitWithWarnings' => true
    })
    xml = Nokogiri::XML(response.to_xml)
    expect(xml.at('//test')).to be_present
  end
end
