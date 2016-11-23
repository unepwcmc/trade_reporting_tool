class CitesReportValidator

  def self.call(aru_id)
    begin
      aru = Trade::AnnualReportUpload.find(aru_id)
    rescue ActiveRecord::RecordNotFound => e
      # catch this exception so that retry is not scheduled
      message = "CITES Report #{aru_id} not found"
      Rails.logger.warn message
      return {
        CITESReportResult: {
          CITESReportId: nil,
          Status: 'UPLOAD_FAILED',
          Message: message
        }
      }
    end

    unless aru.is_submitted?
      aru.process_validation_rules
      aru.validation_report = generate_validation_report(aru)
      aru.validated_at = Time.now
      aru.save

      if aru.persisted_validation_errors.primary.empty? &&
        (aru.persisted_validation_errors.secondary.empty? || aru.force_submit)
        aru.submit
      end
    end

    Api::V1::CITESReportResultBuilder.new(aru).result
    # TODO here be notification logic
  end

  private

  def self.generate_validation_report(aru)
    records = aru.sandbox.shipments
    errors = aru.persisted_validation_errors
    validation_report = {}
    errors.each do |error|
      matching_records = error.validation_rule.matching_records_for_aru_and_error(aru, error)
      matching_records.each do |record|
        record_id = record['id']
        validation_report[record_id] ||= []
        validation_report[record_id] << error.error_message
      end
    end
    validation_report
  end

end
