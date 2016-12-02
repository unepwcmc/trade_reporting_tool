module Sapi
  class User < Sapi::Base
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
    has_many :created_annual_report_uploads, class_name: Trade::AnnualReportUpload, foreign_key: :created_by_id
    has_many :submitted_annual_report_uploads, class_name: Trade::AnnualReportUpload, foreign_key: :submitted_by_id
    has_many :updated_annual_report_uploads, class_name: Trade::AnnualReportUpload, foreign_key: :updated_by_id

    MANAGER = 'admin'
  end
end
