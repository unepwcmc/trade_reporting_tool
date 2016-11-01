require 'rails_helper'

RSpec.describe SapiUser::SessionsController, type: :controller do
  describe "GET new" do
    before(:each) do
      @user = FactoryGirl.create(:sapi_user)
    end
    it "should use Epix::User as resource to login" do
      @request.env['devise.mapping'] = Devise.mappings[:sapi_user]
      sign_in @user
      get :new

      expect(subject.current_sapi_user.class).to eq(Sapi::User)
    end
  end
end
