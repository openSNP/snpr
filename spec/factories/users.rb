# frozen_string_literal: true
FactoryGirl.define do
  factory :user do
    name 'Dogbert'
    sequence(:email) { |i| "fubert#{i}@example.org" }
    password 'strengjeheim'
    password_confirmation 'strengjeheim'
    sex 'yes please'
    yearofbirth '1970'
  end
end
