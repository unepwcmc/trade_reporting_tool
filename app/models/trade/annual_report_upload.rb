class Trade::AnnualReportUpload < Sapi::Base
  self.per_page = 10
  self.table_name = 'trade_annual_report_uploads'

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

  scope :created_by, -> (user_id) { where(epix_created_by_id: user_id) if user_id }
  scope :submitted, -> { where("submitted_at IS NOT NULL") }
  scope :in_progress, -> { where("submitted_at IS NULL") }

  validates :trading_country_id, :epix_created_by_id, :epix_created_at,
    :epix_updated_by_id, :epix_updated_at, presence: true
  validates :point_of_view, inclusion: { in: ['E', 'I'] }

  attr_reader :primary_validation_errors, :secondary_validation_errors

  def file_name
    csv_source_file.try(:path) && File.basename(csv_source_file.path)
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

  def is_submitted?
    submitted_at.present?
  end

  def reported_by_exporter?
    point_of_view == 'E'
  end

  def creator
    sapi_creator || epix_creator
  end

  def user_authorised_to_destroy?(user)
    if creator.is_a?(Epix::User)
      return false if user.is_a?(Sapi::User)
      return (user.id == creator.id ||
        (user.organisation.id == creator.organisation.id && user.is_admin))
    else
      return user.is_a?(Sapi::User) && user.role == 'admin'
    end
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

  def submit
    # TODO
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
