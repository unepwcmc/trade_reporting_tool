module Epix
  class User < Epix::Base
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    has_many :created_annual_report_uploads, class_name: Trade::AnnualReportUpload, foreign_key: :epix_created_by_id
    has_many :submitted_annual_report_uploads, class_name: Trade::AnnualReportUpload, foreign_key: :epix_submitted_by_id
    has_many :updated_annual_report_uploads, class_name: Trade::AnnualReportUpload, foreign_key: :epix_updated_by_id

    belongs_to :organisation, class_name: Epix::Organisation, foreign_key: :organisation_id

    def name
      first_name + ' ' + last_name
    end
  end
end
