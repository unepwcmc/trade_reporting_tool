class CitesReportFromWS
  attr_reader :aru

  def initialize(sapi_country, epix_user, data)
    @type_of_report = data[:type_of_report]
    @submitted_data = data[:submitted_data]
    @force_submit = data[:force_submit]
    @aru = Trade::AnnualReportUpload.new({
      force_submit: @force_submit,
      is_from_web_service: true,
      point_of_view: (@type_of_report == 'E' ? 'E' : 'I'),
      trading_country_id: sapi_country.try(:id),
      epix_created_by_id: epix_user.try(:id),
      epix_updated_by_id: epix_user.try(:id),
      epix_created_at: Time.now,
      epix_updated_at: Time.now
    })
  end

  def save
    Sapi::Base.transaction do
      if @aru.save
        @aru.sandbox.copy_data(@submitted_data)
        @aru.update_attribute(:number_of_rows, @aru.sandbox.shipments.count)
      end
    end
    if @aru.errors.any?
      false
    else
      # needs to happen after transaction committed
      CitesReportValidationJob.perform_later(@aru.id, @aru.force_submit)
      true
    end
  end
end
