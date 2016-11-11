class CitesReportFromWS

  def initialize(sapi_country, epix_user, type_of_report, submitted_data)
    @aru = Sapi::Trade::AnnualReportUpload.new
    @aru.trading_country_id = sapi_country.id
    @aru.point_of_view = (type_of_report == 'E' ? 'E' : 'I')
    @aru.epix_created_by_id = epix_user.id
    @aru.epix_updated_by_id = epix_user.id
    @aru.epix_created_at = Time.now
    @aru.epix_updated_at = @aru.epix_created_at
    @submitted_data = submitted_data
  end

  def save
    result = {}
    Sapi::Base.transaction do
      if @aru.save
        sandbox.copy_data(@submitted_data)
        @aru.update_attribute(:number_of_rows, sandbox_shipments.size)
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

  def sandbox
    return nil unless @aru && !@aru.is_submitted?
    @sandbox ||= Sapi::Trade::Sandbox.new(@aru)
  end

  def sandbox_shipments
    return [] if @aru.is_submitted?
    sandbox.shipments
  end

end
