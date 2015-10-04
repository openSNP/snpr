FactoryGirl.define do
  factory :fitbit_profile do
    after(:create) do |fp, _evaluator|
      params = { fitbit_profile: fp, date_logged: '2013-01-14' }
      FactoryGirl.create(:fitbit_body, params)
      FactoryGirl.create(:fitbit_sleep, params)
      FactoryGirl.create(:fitbit_activity, params)
    end
  end
end
