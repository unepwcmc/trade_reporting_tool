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
end
