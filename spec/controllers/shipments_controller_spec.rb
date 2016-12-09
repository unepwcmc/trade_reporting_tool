require 'rails_helper'

RSpec.describe ShipmentsController, type: :controller do
  CITES_REPORT = {
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
  }
  describe "GET index" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @aru = FactoryGirl.create(:annual_report_upload)
      @aru.sandbox.copy_data(CITES_REPORT)
      @shipment = @aru.sandbox.ar_klass.first
    end

    it "should assigns total number of pages" do
      @request.env['devise.mapping'] = Devise.mappings[:epix_user]
      sign_in @epix_user
      get :index, annual_report_upload_id: @aru

      expect(assigns(:total_pages)).to eq(1)
    end
  end

  describe "GET edit" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @sapi_user = FactoryGirl.create(:sapi_user)
      @aru = FactoryGirl.create(
        :annual_report_upload,
        epix_created_by_id: @epix_user.id
      )
      @aru.sandbox.copy_data(CITES_REPORT)
      @shipment = @aru.sandbox.ar_klass.first
    end

    context "when created by same user" do
      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user
      end
      it "should be successful" do
        get :edit, annual_report_upload_id: @aru, id: @shipment.id

        expect(response.status).to eq(200)
      end
    end

    context "when a different type of user tries to access" do
      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @sapi_user
      end
      it "should redirect to root page" do
        get :edit, annual_report_upload_id: @aru, id: @shipment.id

        expect(subject).to redirect_to root_path
      end
    end
  end

  describe "PATCH update" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @sapi_user = FactoryGirl.create(:sapi_user)
      @aru = FactoryGirl.create(
        :annual_report_upload,
        epix_created_by_id: @epix_user.id
      )
      @aru.sandbox.copy_data(CITES_REPORT)
      @shipment = @aru.sandbox.ar_klass.first
    end

    context "when created by same user" do
      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user
      end
      it "should update record succefully" do
        patch :update, {
          annual_report_upload_id: @aru.id,
          id: @shipment.id,
          "trade_trade_sandbox#{@aru.id}": {
            year: '2011'
          }
        }

        @shipment.reload
        expect(@shipment.year).to eq('2011')
      end

      it "should run validation job" do
        expect(CitesReportValidationJob).to(receive(:perform_later).with(@aru.id, false))
        patch :update, {
          annual_report_upload_id: @aru.id,
          id: @shipment.id,
          "trade_trade_sandbox#{@aru.id}": {
            year: '2011'
          }
        }
      end
    end

    context "when a different type of user tries to access" do
      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @sapi_user
      end
      it "should redirect to root page" do
        patch :update, {
          annual_report_upload_id: @aru.id,
          id: @shipment.id,
          "trade_trade_sandbox#{@aru.id}": {
            year: '2011'
          }
        }

        @shipment.reload
        expect(@shipment.year).to eq('2016')
        expect(subject).to redirect_to root_path
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      request.env['HTTP_REFERER'] = 'http://example.com'
    end
    context "when current user is admin from SAPI" do
      before(:each) do
        @epix_user = FactoryGirl.create(:epix_user)
        @sapi_user = FactoryGirl.create(:sapi_user)
        @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
        sign_in @sapi_user
      end
      context "when aru created by another SAPI user" do
        before(:each) do
          @another_sapi_user = FactoryGirl.create(:sapi_user)
          @aru = FactoryGirl.create(
            :annual_report_upload,
            created_by_id: @another_sapi_user.id
          )
          @aru.sandbox.copy_data(CITES_REPORT)
          @shipment = @aru.sandbox.ar_klass.first
        end
        it "should destroy shipment" do
          expect {
            delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
          }.to change(@aru.sandbox.ar_klass, :count).by(-1)
        end
        it "should run validation job" do
          expect(CitesReportValidationJob).to(receive(:perform_later).with(@aru.id, false))
          delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
        end
      end
      context "when aru created by EPIX user" do
        before(:each) do
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @epix_user.id
          )
          @aru.sandbox.copy_data(CITES_REPORT)
          @shipment = @aru.sandbox.ar_klass.first
        end
        it "should not destroy shipment" do
          expect {
            delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
          }.to change(@aru.sandbox.ar_klass, :count).by(0)
        end
      end
    end
    context "when current user is admin from EPIX" do
      before(:each) do
        @epix_user = FactoryGirl.create(:epix_user, is_admin: true)
        @sapi_user = FactoryGirl.create(:sapi_user)
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user
      end
      context "when aru created by EPIX user from same organisation" do
        before(:each) do
          @organisation = @epix_user.organisation
          @another_epix_user = FactoryGirl.create(:epix_user, organisation: @organisation)
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @another_epix_user.id
          )
          @aru.sandbox.copy_data(CITES_REPORT)
          @shipment = @aru.sandbox.ar_klass.first
        end
        it "should destroy shipment" do
          expect {
            delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
          }.to change(@aru.sandbox.ar_klass, :count).by(-1)
        end
        it "should run validation job" do
          expect(CitesReportValidationJob).to(receive(:perform_later).with(@aru.id, false))
          delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
        end
      end
      context "when aru created by EPIX user from another organisation" do
        before(:each) do
          @another_epix_user = FactoryGirl.create(:epix_user)
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @another_epix_user.id
          )
          @aru.sandbox.copy_data(CITES_REPORT)
          @shipment = @aru.sandbox.ar_klass.first
        end
        it "should not destroy shipment" do
          expect {
            delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
          }.to change(@aru.sandbox.ar_klass, :count).by(0)
        end
      end
    end
    context "when current user is not an admin from EPIX" do
      before(:each) do
        @epix_user = FactoryGirl.create(:epix_user, is_admin: false)
        @sapi_user = FactoryGirl.create(:sapi_user)
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user
      end
      context "when aru created by the same EPIX user" do
        before(:each) do
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @epix_user.id
          )
          @aru.sandbox.copy_data(CITES_REPORT)
          @shipment = @aru.sandbox.ar_klass.first
        end
        it "should destroy shipment" do
          expect {
            delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
          }.to change(@aru.sandbox.ar_klass, :count).by(-1)
        end
        it "should run validation job" do
          expect(CitesReportValidationJob).to(receive(:perform_later).with(@aru.id, false))
          delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
        end
      end
      context "when aru created by EPIX user from same organisation" do
        before(:each) do
          @organisation = @epix_user.organisation
          @another_epix_user = FactoryGirl.create(:epix_user, organisation: @organisation)
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @another_epix_user.id
          )
          @aru.sandbox.copy_data(CITES_REPORT)
          @shipment = @aru.sandbox.ar_klass.first
        end
        it "should not destroy shipment" do
          expect {
            delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
          }.to change(@aru.sandbox.ar_klass, :count).by(0)
        end
      end
      context "when aru created by EPIX user from another organisation" do
        before(:each) do
          @another_epix_user = FactoryGirl.create(:epix_user)
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @another_epix_user.id
          )
          @aru.sandbox.copy_data(CITES_REPORT)
          @shipment = @aru.sandbox.ar_klass.first
        end
        it "should not destroy shipment" do
          expect {
            delete :destroy, { annual_report_upload_id: @aru.id, id: @shipment.id }
          }.to change(@aru.sandbox.ar_klass, :count).by(0)
        end
      end
    end
  end

end
