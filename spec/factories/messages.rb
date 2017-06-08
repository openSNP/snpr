# frozen_string_literal: true

FactoryGirl.define do
  factory :message do
    user
    sent false
    subject 'HELLO WORLD'
    body 'THIS IS AN AWESOME MESSAGE'
  end
end
