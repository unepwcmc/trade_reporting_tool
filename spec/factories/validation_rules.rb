FactoryGirl.define do
  factory :validation_rule, class: Trade::ValidationRule do
    type 'Trade::ValidationRule'
    is_primary true
    run_order 1
  end
end
