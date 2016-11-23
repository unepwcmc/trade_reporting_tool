require "rails_helper"

RSpec.describe CitesReportFromWS, :type => :model do
  let(:sapi_poland){
    FactoryGirl.create(:geo_entity, iso_code2: 'PL')
  }
  let(:epix_user){
    FactoryGirl.create(:epix_user)
  }
  let(:submitted_data){
    {
      CITESReport: [
        {
          CITESReportRow:  {
            TradingPartnerId:  "FR",
            Year:  2016,
            ScientificName:  "Alligator mississipiensis",
            Appendix:  nil,
            TermCode:  "SKI",
            Quantity:  5.0,
            UnitCode:  "KIL",
            SourceCode:  "W",
            PurposeCode:  "Z",
            OriginCountryId:  "US",
            OriginPermitId:  nil,
            ExportPermitId:  "CH123",
            ImportPermitId:  nil
          }
        }, {
          CITESReportRow:  {
            TradingPartnerId:  "FR",
            Year:  2016,
            ScientificName:  "Caiman latirostris",
            Appendix:  "II",
            TermCode:  "SKI",
            Quantity:  5.0,
            UnitCode:  "KIL",
            SourceCode:  "W",
            PurposeCode:  "Z",
            OriginCountryId:  "US",
            OriginPermitId:  nil,
            ExportPermitId:  "CH123",
            ImportPermitId:  nil
          }
        }
      ]
    }
  }
  describe :save do
    it 'is successful' do
      cr = CitesReportFromWS.new(
        sapi_poland,
        epix_user,
        {
          type_of_report: 'E',
          submitted_data: submitted_data,
          force_submit: false
        }
      )
      expect(cr.save).to be(true)
    end
    it 'is not successful when trading country missing' do
      cr = CitesReportFromWS.new(
        nil,
        epix_user,
        {
          type_of_report: 'E',
          submitted_data: submitted_data,
          force_submit: false
        }
      )
      expect(cr.save).to be(false)
    end
  end
end