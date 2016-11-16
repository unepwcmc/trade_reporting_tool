require 'rails_helper'

RSpec.describe AnnualReportUploadsController, type: :controller do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @sapi_user = FactoryGirl.create(:sapi_user)
      @epix_upload = FactoryGirl.create(:annual_report_upload, epix_created_by_id: @epix_user.id)
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
          expect(assigns(:in_progress_pages)).to eq(1)
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
