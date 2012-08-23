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
        originalfilename "foo.txt"
        uploadtime { Time.now }
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
end
