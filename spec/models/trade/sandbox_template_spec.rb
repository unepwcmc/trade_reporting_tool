require "rails_helper"

RSpec.describe Trade::SandboxTemplate, type: :model do
  let(:aru){ FactoryGirl.create(:annual_report_upload) }
  let(:shipment){
    sandbox = aru.sandbox
    sandbox.copy_data({
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
        }
      ]
    })
    sandbox.ar_klass.first
  }

  describe :update do
    it "generates a version with update", versioning: true do
      shipment.update_attributes(year: '2015')

      expect(shipment.versions.size).to eq(1)
      expect(shipment.versions.last.event).to eq('update')
    end
  end
end
