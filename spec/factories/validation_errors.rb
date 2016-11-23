FactoryGirl.define do
  factory :validation_error, class: Trade::ValidationError do
    annual_report_upload
    validation_rule
    matching_criteria '{}'
    is_ignored false
    error_message 'You have an error here'
    error_count 0
  end
end
