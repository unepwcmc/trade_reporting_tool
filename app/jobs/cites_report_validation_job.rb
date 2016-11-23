class CitesReportValidationJob < ApplicationJob
  queue_as :default

  def perform(aru_id)
    Rails.logger.info "Started validation of CITES Report #{aru_id}"
    result = CitesReportValidator.call(aru_id)
    Rails.logger.info "Finished validation of CITES Report #{aru_id}"
  end
end
