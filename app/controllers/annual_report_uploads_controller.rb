class AnnualReportUploadsController < ApplicationController
  respond_to :json

  def index
    @annual_report_uploads = Sapi::Trade::AnnualReportUpload.all
  end
end
