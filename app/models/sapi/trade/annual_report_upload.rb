module Sapi
  class Trade::AnnualReportUpload < Sapi::Base
    self.table_name = 'trade_annual_report_uploads'

    scope :created_by, -> (user_id) { where({created_by_id: user_id, is_from_epix: true}) if user_id }
  end
end
