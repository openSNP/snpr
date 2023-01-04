# frozen_string_literal: true

FactoryBot.define do
  factory :open_humans_profile do
    sequence(:open_humans_user_id) { |n| "oh-user-#{n}" }
  end
end
