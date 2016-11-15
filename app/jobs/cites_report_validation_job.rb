class CitesReportValidationJob < ApplicationJob
  queue_as :default

  def perform(aru_id)
    Rails.logger.info "Started validation of CITES Report #{aru_id}"
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      Rails.logger.warn "CITES Report not found #{aru_id}"
      return
    end
    # TODO:
    Rails.logger.info "Finished validation of CITES Report #{aru_id}"
  end
end
