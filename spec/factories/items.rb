FactoryGirl.define do
  factory :draft, class: Item do
    user nil
    title "MyString"
    body "MyText"
    published_at nil
  end
end
