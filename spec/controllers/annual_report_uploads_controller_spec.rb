require 'rails_helper'

RSpec.describe AnnualReportUploadsController, type: :controller do
  describe "GET index" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @sapi_user = FactoryGirl.create(:sapi_user)
      @epix_upload = FactoryGirl.create(:epix_upload, epix_creator: @epix_user)
      2.times {
        FactoryGirl.create(
          :sapi_upload,
          created_by_id: @sapi_user.id,
          submitted_by_id: @sapi_user.id,
          submitted_at: DateTime.now
        )
      }
    end

    context "Initialise variables" do
      it "should initialise countries" do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user

        get :index

        expect(assigns(:countries).size).to eq(Sapi::GeoEntity.count)
      end

      context "When sapi user" do
        it "should initialise total pages" do
          @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
          sign_in @sapi_user

          get :index

          expect(assigns(:submitted_pages)).to eq(1)
          expect(assigns(:in_progress_pages)).to eq(0)
        end
      end

      context "When epix user" do
        it "should initialise total pages" do
          @request.env['devise.mapping'] = Devise.mappings[:epix_user]
          sign_in @epix_user

          get :index

          expect(assigns(:submitted_pages)).to eq(0)
          expect(assigns(:in_progress_pages)).to eq(1)
        end
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @sapi_user = FactoryGirl.create(:sapi_user)
      @epix_upload = FactoryGirl.create(:annual_report_upload, epix_creator: @epix_user)
      2.times {
        FactoryGirl.create(
          :annual_report_upload,
          created_by_id: @sapi_user.id,
          submitted_by_id: @sapi_user.id,
          submitted_at: DateTime.now
        )
      }
    end

    context "Initialise variables" do
      it "should assign annual_report_upload" do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user

        get :show, params: {
          id: @epix_upload.id
        }
        expect(assigns(:annual_report_upload).present?).to be(true)
      end
    end
  end

  describe "GET changes_history" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @sapi_user = FactoryGirl.create(:sapi_user)
      @epix_upload = FactoryGirl.create(:annual_report_upload, epix_creator: @epix_user)
      2.times {
        FactoryGirl.create(
          :annual_report_upload,
          created_by_id: @sapi_user.id,
          submitted_by_id: @sapi_user.id,
          submitted_at: DateTime.now
        )
      }
      sandbox = @epix_upload.sandbox
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
      @sandbox_template = sandbox.ar_klass.first
      @sandbox_template.update_attributes(year: 2015)
    end

    context "Initialise variables" do
      it "should assign annual_report_upload" do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user

        get 'changes_history', params: {
          id: @epix_upload.id
        }
        expect(assigns(:annual_report_upload).present?).to be(true)
      end
    end

    it "should assign total_pages", versioning: true do
      @request.env['devise.mapping'] = Devise.mappings[:epix_user]
      sign_in @epix_user

      get 'changes_history', params: {
        id: @epix_upload.id
      }
      expect(assigns(:total_pages)).to eq(1)
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
        end
        it "should destroy aru" do
          expect {
            delete :destroy, params: {
              id: @aru.id
            }
          }.to change(Trade::AnnualReportUpload, :count).by(-1)
        end
      end
      context "when aru created by EPIX user" do
        before(:each) do
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @epix_user.id
          )
        end
        it "should not destroy aru" do
          expect {
            delete :destroy, params: {
              id: @aru.id
            }
          }.to change(Trade::AnnualReportUpload, :count).by(0)
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
        end
        it "should destroy aru" do
          expect {
            delete :destroy, params: {
              id: @aru.id
            }
          }.to change(Trade::AnnualReportUpload, :count).by(-1)
        end
      end
      context "when aru created by EPIX user from another organisation" do
        before(:each) do
          @another_epix_user = FactoryGirl.create(:epix_user)
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @another_epix_user.id
          )
        end
        it "should destroy aru" do
          expect {
            delete :destroy, params: {
              id: @aru.id
            }
          }.to change(Trade::AnnualReportUpload, :count).by(0)
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
        end
        it "should destroy aru" do
          expect {
            delete :destroy, params: {
              id: @aru.id
            }
          }.to change(Trade::AnnualReportUpload, :count).by(-1)
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
        end
        it "should destroy aru" do
          expect {
            delete :destroy, params: {
              id: @aru.id
            }
          }.to change(Trade::AnnualReportUpload, :count).by(0)
        end
      end
      context "when aru created by EPIX user from another organisation" do
        before(:each) do
          @another_epix_user = FactoryGirl.create(:epix_user)
          @aru = FactoryGirl.create(
            :annual_report_upload,
            epix_created_by_id: @another_epix_user.id
          )
        end
        it "should destroy aru" do
          expect {
            delete :destroy, params: {
              id: @aru.id
            }
          }.to change(Trade::AnnualReportUpload, :count).by(0)
        end
      end
    end
  end

  describe "GET download_error_report" do
    context "when validation report has been generated" do
      before(:each) do
        @epix_user = FactoryGirl.create(:epix_user)
        @aru = FactoryGirl.create(:epix_upload)
        allow(CitesReportValidator).to(
          receive(:generate_validation_report).and_return(
            {'0' => {'data' => {"appendix": "II"}, 'errors' => []}}
          )
        )
        allow_any_instance_of(Trade::AnnualReportUpload).to(
          receive_message_chain(:persisted_validation_errors, :primary).and_return([])
        )
        allow_any_instance_of(Trade::AnnualReportUpload).to(
          receive_message_chain(:persisted_validation_errors, :secondary).and_return([])
        )
        allow_any_instance_of(Trade::AnnualReportUpload).to(
          receive(:submit).with(@epix_user)
        )
        allow_any_instance_of(Trade::Sandbox).to(
          receive(:copy_from_sandbox_to_shipments).with(@epix_user).and_return(true)
        )
        CitesReportValidator.call(@aru.id, @epix_user)
      end
      it "should download validation report" do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user

        get 'download_error_report', params: {
          id: @aru.id
        }
        expect(response.content_type).to eq('application/zip')
        expect(response.body).to include("validation_report.csv")
        expect(response.body).to include("changelog.csv")
      end
    end
  end
end
