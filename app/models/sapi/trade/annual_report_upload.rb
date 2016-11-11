module Sapi
  class Trade::AnnualReportUpload < Sapi::Base
    self.table_name = 'trade_annual_report_uploads'

    belongs_to :trading_country, class_name: Sapi::GeoEntity,
      foreign_key: :trading_country_id
    belongs_to :epix_creator, class_name: Epix::User,
      foreign_key: :epix_created_by_id
    belongs_to :epix_updater, class_name: Epix::User,
      foreign_key: :epix_updated_by_id

    scope :created_by, -> (user_id) { where(epix_created_by_id: user_id) if user_id }
    scope :submitted, -> { where("submitted_at IS NOT NULL") }
    scope :in_progress, -> { where("submitted_at IS NULL") }

    validates :trading_country_id, :epix_created_by_id, :epix_created_at,
      :epix_updated_by_id, :epix_updated_at, presence: true

    def is_submitted?
      submitted_at.present?
    end
  end
end
