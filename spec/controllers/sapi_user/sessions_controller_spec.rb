require 'rails_helper'

RSpec.describe SapiUser::SessionsController, type: :controller do
  describe "GET new" do
    before(:each) do
      @user = FactoryGirl.create(:sapi_user)
      @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
      @request.env['HTTP_REFERER'] = 'http://test.host/sapi/users/sign_in?user="email"'
      sign_in @user
    end
    it "should use Epix::User as resource to login" do
      get :new

      expect(subject.current_sapi_user.class).to eq(Sapi::User)
    end

    it "should redirect to annual report uploads index page" do
      get :new

      expect(response).to redirect_to(annual_report_uploads_path)
    end
  end

  describe "POST create" do
    context "when user is not an admin" do
      before(:each) do
        @user = FactoryGirl.create(:sapi_user, role: '')
        @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
        @request.env['HTTP_REFERER'] = 'http://test.host/sapi/users/sign_in?user="email"'
      end
      it "should redirect to login because unauthorised" do
        post :create, sapi_user: {email: @user.email }

        expect(response).to redirect_to(new_sapi_user_session_path)
      end
    end
    context "when user is admin" do
      before(:each) do
        @user = FactoryGirl.create(:sapi_user)
        @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
        @request.env['HTTP_REFERER'] = 'http://test.host/sapi/users/sign_in?user="email"'
      end
      it "should login correctly" do
        post :create, sapi_user: {email: @user.email }

        expect(response.status).to eq(200)
      end
    end
  end

end
