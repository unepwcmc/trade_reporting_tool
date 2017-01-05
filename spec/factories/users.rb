FactoryGirl.define do
  factory :epix_user, class: Epix::User, aliases: [:epix_creator, :epix_updater] do
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    password { Faker::Internet.password(10, 20) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    organisation
    is_admin false
  end

  factory :sapi_user, class: Sapi::User, aliases: [:sapi_creator, :sapi_updater] do
    sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    password { Faker::Internet.password(10, 20) }
    name { Faker::Name.first_name }
    role 'admin'
  end
end
