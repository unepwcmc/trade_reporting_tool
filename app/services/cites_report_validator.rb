class CitesReportValidator

  def self.call(aru_id, send_email=true)
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

    if send_email
      validation_report = Api::V1::CITESReportResultBuilder.new(aru).result
      validation_report_csv_file = ValidationReportCsvGenerator.call(aru)

      NotificationMailer.validation_result(
        aru.epix_creator || aru.sapi_creator, aru, validation_report, validation_report_csv_file
      ).deliver
    end

    validation_report
  end

  private

  def self.generate_validation_report(aru)
    records = aru.sandbox.shipments
    errors = aru.persisted_validation_errors
    errors_by_record = {}
    errors.each do |error|
      matching_records = error.validation_rule.matching_records_for_aru_and_error(aru, error)
      matching_records.each do |record|
        record_id = record['id']
        errors_by_record[record_id] ||= []
        errors_by_record[record_id] << error.error_message
      end
    end
    Hash[
      records.each_with_index.map do |record, index|
        [
          index,
          {
            data: record.attributes,
            errors: errors_by_record[record['id']]
          }
        ]
    end
    ]
  end

end
