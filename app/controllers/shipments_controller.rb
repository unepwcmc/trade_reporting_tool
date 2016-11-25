class ShipmentsController < ApplicationController
  def index
    shipments = Trade::SandboxTemplate.all
    per_page = Trade::SandboxTemplate.per_page
    @total_pages = (shipments.count / per_page.to_f).ceil
  end
end
