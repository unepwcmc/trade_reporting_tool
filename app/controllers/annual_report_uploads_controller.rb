class AnnualReportUploadsController < ApplicationController
  respond_to :json

  def index
    epix_user_id = current_epix_user && current_epix_user.id
    @annual_report_uploads =
      Sapi::Trade::AnnualReportUpload.created_by(epix_user_id).map do |aru|
        AnnualReportUploadSerializer.new(aru)
      end
  end
end
