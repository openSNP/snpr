# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    user
    sent false
    subject 'HELLO WORLD'
    body 'THIS IS AN AWESOME MESSAGE'
  end
end
