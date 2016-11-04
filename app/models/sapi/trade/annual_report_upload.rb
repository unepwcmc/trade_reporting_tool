module Sapi
  class Trade::AnnualReportUpload < Sapi::Base
    self.table_name = 'trade_annual_report_uploads'

    belongs_to :trading_country, class_name: Sapi::GeoEntity, foreign_key: :trading_country_id

    scope :created_by, -> (user_id) { where(epix_created_by_id: user_id) if user_id }
  end
end
