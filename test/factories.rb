# Needed (?) when test/unit and Rspec tests are run
unless $factories_already_read
  $factories_already_read = true

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
      sequence(:name) { |i| "rs#{i}" }
      sequence(:position) { |i| i }
      sequence(:chromosome) { |i| i }
      genotype_frequency("AA" => 1)
      allele_frequency("A" => 0, "T" => 0, "G" => 0, "C" => 0)
      ranking 0
    end

    factory :snp_comment do
      comment_text "This is a great SNP!"
      subject "Great!"
      user_id 1
      snp_id 1
    end

    factory :user_snp do
      local_genotype 'AG'
      genotype
      user
      snp
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

    factory :mendeley_paper do
      title "Musterstudie"
      uuid { UUIDTools::UUID.random_create }
      first_author "Max Mustermann"
      mendeley_url "http://example.com"
      doi "10.1000/182"
      pub_year 2013
    end

    factory :plos_paper do
      title 'A PLOS Paper'
    end

    factory :snpedia_paper do
    end

    factory :genome_gov_paper do
      title 'A Genome.gov Paper'
    end
  end
end
