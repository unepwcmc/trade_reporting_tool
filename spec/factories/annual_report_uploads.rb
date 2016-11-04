FactoryGirl.define do
  factory :annual_report_upload, class: Sapi::Trade::AnnualReportUpload do
    trading_country
    point_of_view 'E'
  end
end
