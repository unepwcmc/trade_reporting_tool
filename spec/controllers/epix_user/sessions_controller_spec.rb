require 'rails_helper'

RSpec.describe EpixUser::SessionsController, type: :controller do
  describe "GET new" do
    before(:each) do
      @user = FactoryGirl.create(:epix_user)
      @request.env['devise.mapping'] = Devise.mappings[:epix_user]
      @request.env['HTTP_REFERER'] = 'http://test.host/epix/users/sign_in?user="email"'
      sign_in @user
    end
    it "should use Epix::User as resource to login" do
      get :new

      expect(subject.current_epix_user.class).to eq(Epix::User)
    end

    it "should redirect to annual report uploads index page" do
      get :new

      expect(response).to redirect_to(annual_report_uploads_path)
    end
  end

  describe "POST create" do
    context "when user is not of an authorised organisation" do
      before(:each) do
        @organisation = FactoryGirl.create(:organisation, role: 'Other')
        @user = FactoryGirl.create(:epix_user, organisation: @organisation)
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        @request.env['HTTP_REFERER'] = 'http://test.host/epix/users/sign_in?user="email"'
      end
      it "should redirect to login because unauthorised" do
        post :create, epix_user: {email: @user.email }

        expect(response).to redirect_to(new_epix_user_session_path)
      end
    end
    context "when user is of an authorised organisation" do
      before(:each) do
        @organisation = FactoryGirl.create(:organisation, role: 'CITES MA')
        @user = FactoryGirl.create(:epix_user, organisation: @organisation)
        @request.env['devise.mapping'] = Devise.mappings[:epix_user]
        @request.env['HTTP_REFERER'] = 'http://test.host/epix/users/sign_in?user="email"'
      end
      it "should login correctly" do
        post :create, epix_user: {email: @user.email }

        expect(response.status).to eq(200)
      end
    end
  end
end
