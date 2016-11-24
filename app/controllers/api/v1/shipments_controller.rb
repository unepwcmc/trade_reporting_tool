class Api::V1::ShipmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @shipments = Trade::SandboxTemplate.all.paginate(
      page: params[:shipments]).map do |shipment|
        SandboxShipmentSerializer.new(shipment)
      end

    render json: {
      shipments: @shipments
    }
  end

  private

  def authenticate_user!
    render "unauthorised" unless (current_epix_user || current_sapi_user).present?
  end
end
