class Trade::ValidationError < Sapi::Base
  self.table_name = 'trade_validation_errors'
  belongs_to :annual_report_upload, class_name: Trade::AnnualReportUpload
  belongs_to :validation_rule, class_name: Trade::ValidationRule
end
