FactoryGirl.define do
  factory :item do
    user nil
    title "MyString"
    body "MyText"
    published_at { Time.zone.now }
  end
end
