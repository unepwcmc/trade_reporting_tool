require 'rails_helper'

RSpec.describe EpixUser::SessionsController, type: :controller do
  describe "GET new" do
    before(:each) do
      @user = FactoryGirl.create(:epix_user)
    end
    it "should use Epix::User as resource to login" do
      @request.env['devise.mapping'] = Devise.mappings[:epix_user]
      sign_in @user
      get :new

      expect(subject.current_epix_user.class).to eq(Epix::User)
    end
  end
end
