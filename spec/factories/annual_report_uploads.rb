FactoryGirl.define do
  factory :annual_report_upload, class: Trade::AnnualReportUpload do
    trading_country
    point_of_view 'E'
    force_submit false

    factory :sapi_upload do
      sapi_creator
      created_at { Time.now }
      sapi_updater
      updated_at { Time.now }
    end

    factory :epix_upload do
      epix_creator
      epix_created_at { Time.now }
      epix_updater
      epix_updated_at { Time.now }
    end
  end
end
