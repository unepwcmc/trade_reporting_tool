class Trade::ValidationError < Sapi::Base
  self.table_name = 'trade_validation_errors'
  belongs_to :annual_report_upload, class_name: Trade::AnnualReportUpload
  belongs_to :validation_rule, class_name: Trade::ValidationRule

  scope :primary, -> { where(is_primary: true) }
  scope :secondary, -> { where(is_primary: false) }
end
