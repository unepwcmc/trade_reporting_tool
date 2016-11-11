module Sapi
  class Trade::AnnualReportUpload < Sapi::Base
    self.table_name = 'trade_annual_report_uploads'

    belongs_to :trading_country, class_name: Sapi::GeoEntity, foreign_key: :trading_country_id
    belongs_to :epix_submitter, class_name: Epix::User, foreign_key: :epix_submitted_by_id
    belongs_to :sapi_submitter, class_name: Sapi::User, foreign_key: :submitted_by_id

    scope :created_by, -> (user_id) { where(epix_created_by_id: user_id) if user_id }
    scope :submitted, -> { where("submitted_at IS NOT NULL") }
    scope :in_progress, -> { where("submitted_at IS NULL") }

  end
end
