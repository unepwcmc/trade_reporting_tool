class CitesReportFromWS

  def initialize(sapi_country, epix_user, data)
    @type_of_report = data[:type_of_report]
    @submitted_data = data[:submitted_data]
    @force_submit = data[:force_submit]
    @aru = Trade::AnnualReportUpload.new({
      is_from_web_service: true,
      point_of_view: (@type_of_report == 'E' ? 'E' : 'I'),
      trading_country_id: sapi_country.id,
      epix_created_by_id: epix_user.id,
      epix_updated_by_id: epix_user.id,
      epix_created_at: Time.now,
      epix_updated_at: Time.now
    })
  end

  def save
    result = {}
    Sapi::Base.transaction do
      if @aru.save
        sandbox.copy_data(@submitted_data)
        @aru.update_attribute(:number_of_rows, sandbox_shipments.size)
        CitesReportValidationJob.perform_later @aru.id
        result[:Status] = 'SUCCESS'
        result[:Message] = 'Data queued for validation'
        result[:CITESReportId] = @aru.id
      else
        result[:Status] = 'ERROR'
        result[:Message] = 'Failed to queue data for validation'
        result[:Details] = @aru.errors
      end
    end
    result
  end

end
