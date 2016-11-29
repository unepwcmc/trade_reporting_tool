require 'rails_helper'

RSpec.describe Api::V1::AnnualReportUploadsController, type: :controller do
  describe "GET index" do
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

    context "when logging in from epix" do
      it "should show uploads from epix user" do
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        sign_in @epix_user
        get :index

        expect(assigns(:annual_report_uploads).size).to eq(1)
      end
    end

    context "when logging in from sapi" do
      it "should show uploads from sapi user" do
        @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
        sign_in @sapi_user
        get :index

        expect(assigns(:annual_report_uploads).size).to eq(3)
      end
    end

    context "filter by submitted and in progress" do
      it "should assign only submitted uploads" do
        @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
        sign_in @sapi_user
        get :index

        expect(assigns(:submitted_uploads).size).to eq(2)
      end

      it "should assign only in progress uploads" do
        @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
        sign_in @sapi_user
        get :index

        expect(assigns(:in_progress_uploads).size).to eq(1)
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
      @sandbox_template = FactoryGirl.create(:sandbox_template, year: '2016')
      @sandbox_template.update_attributes!(year: '2015')
    end

    #context "Retrieve shipments" do
    #  it "should get shipments with changes only", versioning: true do
    #    @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
    #    sign_in @sapi_user

    #    get :changes_history, id: @epix_upload.id

    #    expect(assigns(:shipments).size).to eq(1)
    #  end
    #end
  end
end
