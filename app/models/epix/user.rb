module Epix
  class User < Epix::Base
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    has_many :created_annual_report_uploads, class_name: Sapi::Trade::AnnualReportUpload, foreign_key: :epix_created_by_id
    has_many :submitted_annual_report_uploads, class_name: Sapi::Trade::AnnualReportUpload, foreign_key: :epix_submitted_by_id
    belongs_to :organisation, class_name: Epix::Organisation, foreign_key: :organisation_id
  end
end
