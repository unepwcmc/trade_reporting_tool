class Api::V1::CITESReportResultBuilder

  def initialize(aru)
    @aru = aru
    @status, @message = if @aru.new_record? && @aru.errors.any?
      [
        'UPLOAD_FAILED',
        upload_failed_message
      ]
    elsif @aru.is_submitted?
      [
        'SUBMITTED',
        submitted_message
      ]
    elsif @aru.persisted_validation_errors.primary.any? ||
      @aru.persisted_validation_errors.secondary.any? && !@aru.force_submit
      [
        'VALIDATION_FAILED',
        validation_failed_message
      ]
    else
      [
        'PENDING',
        pending_message
      ]
    end
    if @aru.validation_report.present?
      @validation_report = @aru.validation_report
    end
  end

  def result
    result = {
      CITESReportResult: {
        CITESReportId: @aru.id,
        Status: @status,
        Message: @message
      }
    }
    if @validation_report
      result[:CITESReportResult][:ErrorReport] = @validation_report.keys.each_with_index.map do |record_id, index|
          {
            CITESReportRowResult: {
              RowIndex: index,
              Errors: @validation_report[record_id]
            }
          }
      end
    end
    result
  end

  private

  def submitted_message
    [
      'Successfully submitted to CITES TradeDB',
      'on', @aru.submitted_at,
      'by', (@aru.epix_submitter || @aru.sapi_submitter).name
    ].join(' ')
  end

  def validation_failed_message
    parts = [
      'Validation failed with'
    ]
    primary_cnt = @aru.persisted_validation_errors.primary.count
    if primary_cnt > 0
      parts += [primary_cnt, 'primary errors']
    end
    secondary_cnt = @aru.persisted_validation_errors.secondary.count
    if secondary_cnt > 0
      parts += [secondary_cnt, 'secondary errors']
    end
    parts += ['on', @aru.validated_at]
    if @aru.force_submit
      parts <<  'with force submit option'
    end
    parts.join(' ')
  end

  def pending_message
    [
      'Successfully uploaded to EPIX',
      'on', @aru.created_at,
      'by', (@aru.epix_creator || @aru.sapi_creator).name,
      'pending validation.'
    ].join(' ')
  end

  def upload_failed_message
    [
      'Failed to upload to EPIX',
      'on', @aru.created_at,
      'by', (@aru.epix_creator || @aru.sapi_creator).name
    ].join(' ')
  end
end
