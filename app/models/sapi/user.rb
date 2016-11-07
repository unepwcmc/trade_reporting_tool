module Sapi
  class User < Sapi::Base
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
    has_many :annual_report_uploads, class_name: Sapi::Trade::AnnualReportUpload, foreign_key: :created_by_id
  end
end
