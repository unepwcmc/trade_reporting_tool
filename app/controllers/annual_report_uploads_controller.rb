class AnnualReportUploadsController < ApplicationController
  respond_to :json

  def index
    @annual_report_uploads =
      Sapi::Trade::AnnualReportUpload.all.map do |aru|
        AnnualReportUploadSerializer.new(aru)
      end
  end
end
