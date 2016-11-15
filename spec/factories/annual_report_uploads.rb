FactoryGirl.define do
  factory :annual_report_upload, class: Trade::AnnualReportUpload do
    trading_country
    point_of_view 'E'
    epix_created_at { Time.now }
    epix_creator
    epix_updated_at { Time.now }
    epix_updater
  end
end
