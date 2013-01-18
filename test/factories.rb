FactoryGirl.define do
  factory :user do
    name "Dogbert"
    sequence(:email) { |i| "fubert#{i}@example.org" }
    password "jeheim"
    password_confirmation "jeheim"
    sex 'yes please'
    yearofbirth '1970'
  end

  factory :genotype do
    genotype_file_name "foo.txt"
    association :user
  end

  factory :snp do
    sequence(:name) { |i| "name #{i}" }
    sequence(:position) { |i| i }
    sequence(:chromosome) { |i| i }
    genotype_frequency("AA" => 1)
    allele_frequency("A" => 0, "T" => 0, "G" => 0, "C" => 0)
    ranking 0
  end

  factory :achievement do
    award "Foooooooo"
  end

  factory :phenotype do
    characteristic "Penis length"
  end

  factory :user_phenotype do
    association :user
    association :phenotype
    variation "pink"
  end

  factory :picture_phenotype do
    characteristic 'Eye color'
  end

  factory :user_picture_phenotype do
    variation 'pink'
  end

  factory :fitbit_profile do
    after(:create) do |fp, evaluator|
      params = { fitbit_profile: fp, date_logged: '2013-01-14' }
      FactoryGirl.create(:fitbit_body, params)
      FactoryGirl.create(:fitbit_sleep, params)
      FactoryGirl.create(:fitbit_activity, params)
    end
  end

  factory :fitbit_body do
    weight "100"
    bmi "200"
  end

  factory :fitbit_sleep do
    minutes_asleep 480
    minutes_awake 10
    number_awakenings 1
    minutes_to_sleep 10
  end

  factory :fitbit_activity do
    steps 100
    floors 1
  end
end
