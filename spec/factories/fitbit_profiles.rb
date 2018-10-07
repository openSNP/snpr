# frozen_string_literal: true

FactoryBot.define do
  factory :fitbit_profile do
    after(:create) do |fp, _evaluator|
      params = { fitbit_profile: fp, date_logged: '2013-01-14' }
      FactoryBot.create(:fitbit_body, params)
      FactoryBot.create(:fitbit_sleep, params)
      FactoryBot.create(:fitbit_activity, params)
    end
  end
end
