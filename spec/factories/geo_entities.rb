FactoryGirl.define do
  factory :geo_entity_type, class: Sapi::GeoEntityType do
    name 'COUNTRY'
  end

  factory :geo_entity, :aliases => [:trading_country], class: Sapi::GeoEntity do
    geo_entity_type
    name_en 'Wonderland'
    sequence(:iso_code2) { |n| [n, n + 1].map { |i| (65 + i % 26).chr }.join }
    is_current true
  end

  factory :country, class: Epix::Country do
    name 'Wonderland'
    iso_code2 'WW'
  end
end
