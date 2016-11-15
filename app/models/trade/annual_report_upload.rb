class Trade::AnnualReportUpload < Sapi::Base
  self.per_page = 10
  self.table_name = 'trade_annual_report_uploads'

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

  scope :created_by, -> (user_id) { where(epix_created_by_id: user_id) if user_id }
  scope :submitted, -> { where("submitted_at IS NOT NULL") }
  scope :in_progress, -> { where("submitted_at IS NULL") }

  validates :trading_country_id, :epix_created_by_id, :epix_created_at,
    :epix_updated_by_id, :epix_updated_at, presence: true

  attr_reader :primary_validation_errors, :secondary_validation_errors

  # object that represents the particular sandbox table linked to this annual
  # report upload
  def sandbox
    return nil if is_submitted?
    @sandbox ||= Trade::Sandbox.new(self)
  end

  def is_submitted?
    submitted_at.present?
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
