require 'rails_helper'

RSpec.describe Api::V1::ShipmentsController, type: :controller do
  describe "GET index" do
    before(:each) do
      @epix_user = FactoryGirl.create(:epix_user)
      @shipment = FactoryGirl.create(:sandbox_template)
    end

    it "should assign shipments" do
      @request.env['devise.mapping'] = Devise.mappings[:epix_user]
      sign_in @epix_user
      get :index

      expect(assigns(:shipments).size).to eq(1)
    end
  end
end
