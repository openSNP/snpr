FactoryGirl.define do
  factory :user do
    name 'Dogbert'
    sequence(:email) { |i| "fubert#{i}@example.org" }
    password 'jeheim'
    password_confirmation 'jeheim'
    sex 'yes please'
    yearofbirth '1970'
  end
end
