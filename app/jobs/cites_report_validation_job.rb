class CitesReportValidationJob < ApplicationJob
  queue_as :default

  def perform(aru_id, force_submit)
    Rails.logger.info "Started validation of CITES Report #{aru_id}"
    CitesReportValidator.call(aru_id, force_submit)
    Rails.logger.info "Finished validation of CITES Report #{aru_id}"
  end
end
