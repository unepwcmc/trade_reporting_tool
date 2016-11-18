class CitesReportValidator

  def self.call(aru_id, force_submit)
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      message = "CITES Report #{aru_id} not found"
      Rails.logger.warn message
      return {
        Status: 'ERROR',
        Message: message
      }
    end
    result = {}
    aru.process_validation_rules
    if !aru.primary_validation_errors.empty?
      result[:Status] = 'ERROR'
      result[:Message] = 'Primary errors detected in CITES Report'
      # TODO: here we go with errors row by row
    elsif !aru.secondary_validation_errors.empty? && !force_submit
      result[:Status] = 'ERROR'
      result[:Message] = 'Secondary errors detected in CITES Report'
      # TODO: here we go with errors row by row
    else
      result[:Status] = 'SUCCESS'
      # TODO: proceed with submission
    end
    Rails.logger.info result
    result
  end

end