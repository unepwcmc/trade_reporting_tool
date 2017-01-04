class Trade::AnnualReportUpload < Sapi::Base
  self.per_page = 10
  self.table_name = 'trade_annual_report_uploads'

  SHIPMENTS_LIMIT = 10

  has_many :persisted_validation_errors, class_name: Trade::ValidationError,
    foreign_key: :annual_report_upload_id
  belongs_to :trading_country, class_name: Sapi::GeoEntity,
    foreign_key: :trading_country_id
  belongs_to :epix_creator, class_name: Epix::User,
    foreign_key: :epix_created_by_id, optional: true
  belongs_to :sapi_creator, class_name: Sapi::User,
    foreign_key: :created_by_id, optional: true
  belongs_to :epix_updater, class_name: Epix::User,
    foreign_key: :epix_updated_by_id, optional: true
  belongs_to :sapi_updater, class_name: Sapi::User,
    foreign_key: :updated_by_id, optional: true
  belongs_to :epix_submitter, class_name: Epix::User,
    foreign_key: :epix_submitted_by_id, optional: true
  belongs_to :sapi_submitter, class_name: Sapi::User,
    foreign_key: :submitted_by_id, optional: true

  scope :created_by, -> (user_id, user_type) {
    if user_type == 'epix'
      where(epix_created_by_id: user_id)
    else
      where("epix_created_by_id IS NULL")
    end
  }
  scope :submitted, -> { where("submitted_at IS NOT NULL OR epix_submitted_at IS NOT NULL") }
  scope :in_progress, -> { where("submitted_at IS NULL AND epix_submitted_at IS NULL") }

  validates :trading_country_id, presence: true
  validates :point_of_view, inclusion: { in: ['E', 'I'] }

  attr_reader :primary_validation_errors, :secondary_validation_errors

  def file_name
    csv_source_file
  end

  def summary
    _created_at = (epix_created_at || created_at).strftime("%d/%m/%y")
    _created_by = (epix_creator || sapi_creator).name
    trading_country.name_en + ' (' + point_of_view + '), ' +
      number_of_rows.to_s + ' shipments' + ' uploaded on ' + _created_at +
      ' by ' + _created_by + ' ('  + (file_name || '') + ')'
  end
  # object that represents the particular sandbox table linked to this annual
  # report upload

  def validation_errors
    @primary_validation_errors || @secondary_validation_errors
  end

  def sandbox
    return nil if is_submitted?
    @sandbox ||= Trade::Sandbox.new(self)
  end

  def shipments_with_versions(page=nil)
    return [] unless sandbox
    shipments = ar_klass = sandbox.ar_klass
    if page
      offset = SHIPMENTS_LIMIT * (page.to_i - 1)
      shipments = shipments.limit(SHIPMENTS_LIMIT).offset(offset)
    end
    shipments.joins(
      "JOIN versions v on v.item_id = #{ar_klass.table_name}.id"
    ).uniq
  end

  def is_submitted?
    submitted_at.present?
  end

  def reported_by_exporter?
    point_of_view == 'E'
  end

  def creator
    sapi_creator || epix_creator
  end

  def destroy_with_sandbox
    destroyed = false
    self.transaction do
      self.sandbox.try(:destroy)
      destroyed = self.destroy
    end
    destroyed
  end

  def process_validation_rules
    @primary_validation_errors = run_validations(
      Trade::ValidationRule.where(is_primary: true)
    )
    unless @primary_validation_errors.present?
      @secondary_validation_errors = run_validations(
        Trade::ValidationRule.where(is_primary: false)
      )
    end
  end

  def run_primary_validations
    @validation_errors = run_validations(
      Trade::ValidationRule.where(:is_primary => true)
    )
  end

  def submit(submitter)
    run_primary_validations
    unless @validation_errors.count == 0
      self.errors[:base] << "Submit failed, primary validation errors present."
      return false
    end

    return false unless sandbox.copy_from_sandbox_to_shipments(submitter)

    # generate changelog
    ChangesHistoryGeneratorJob.perform_later(self.id, submitter, true)

    update_column(:number_of_records_submitted, sandbox.moved_rows_cnt)

    # flag as submitted
    submitter_type = submitter.class.to_s.split(':').first
    if submitter_type == 'Epix'
      update_column(:epix_submitted_at, DateTime.now)
      update_column(:epix_submitted_by_id, submitter.id)
    else
      update_column(:submitted_at, DateTime.now)
      update_column(:submitted_by_id, submitter.id)
    end

    # clear downloads cache
    DownloadsCache.clear_shipments
  end

  def save_wo_timestamps
    class << self
      def record_timestamps; false; end
    end

    begin
      self.save
    ensure
      class << self
        remove_method :record_timestamps
      end
    end
  end

  private

  # Expects a relation object
  def run_validations(validation_rules)
    validation_errors = []
    validation_rules.order(:run_order).each do |vr|
      vr.refresh_errors_if_needed(self)
      validation_errors << vr.validation_errors_for_aru(self)
    end
    validation_errors.flatten
  end
end
