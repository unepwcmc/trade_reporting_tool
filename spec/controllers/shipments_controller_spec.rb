require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  describe "GET index" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @aru = FactoryGirl.create(:annual_report_upload)
      @aru.sandbox.copy_data({
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
      @shipment = @aru.sandbox.ar_klass.first
    end

    it "should assigns total number of pages" do
      @request.env['devise.mapping'] = Devise.mappings[:epix_user]
      sign_in @epix_user
      get :index, annual_report_upload_id: @aru

      expect(assigns(:total_pages)).to eq(1)
    end
  end
end
