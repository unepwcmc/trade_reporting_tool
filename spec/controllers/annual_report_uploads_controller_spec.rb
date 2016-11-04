require 'rails_helper'

RSpec.describe AnnualReportUploadsController, type: :controller do
  describe "GET index" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @sapi_user = FactoryGirl.create(:sapi_user)
      @epix_upload = FactoryGirl.create(:annual_report_upload, epix_created_by_id: @epix_user.id)
      2.times { FactoryGirl.create(:annual_report_upload, created_by_id: @sapi_user.id) }
    end

    context "when logging in from epix" do
      it "should show uploads from epix user" do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user
        get :index

        expect(assigns(:annual_report_uploads).size).to eq(1)
      end
    end

    context "when logging in from sapi" do
      it "should show uploads from epix user" do
        @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
        sign_in @sapi_user
        get :index

        expect(assigns(:annual_report_uploads).size).to eq(3)
      end
    end
  end
end
