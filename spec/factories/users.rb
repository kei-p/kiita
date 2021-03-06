# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "name_#{n}" }
    sequence(:email) { |n| "mail_#{n}@exmaple.com" }

    trait :registered do
      password 'password'
      password_confirmation 'password'
    end
  end
end
