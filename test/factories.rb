FactoryGirl.define do
    factory :user do |u|
  u.name "Dogbert"
  u.sequence(:email) { |i| "fubert#{i}@example.org" }
  u.password "jeheim"
  u.password_confirmation "jeheim"
  u.sex 'yes please'
  u.yearofbirth '1970'
    end
end

FactoryGirl.define do
    factory :genotype do |g|
    g.originalfilename "foo.txt"
    g.uploadtime { Time.now }
    g.association :user
    end
end

FactoryGirl.define do
  factory :snp do |s|
    s.sequence(:name) { |i| "name #{i}" }
    s.sequence(:position) { |i| i }
    s.sequence(:chromosome) { |i| i }
    s.genotype_frequency("AA" => 1)
    s.allele_frequency("A" => 0, "T" => 0, "G" => 0, "C" => 0)
    s.ranking 0
  end
end

FactoryGirl.define do
    factory :achievement do |a|
  a.award "Foooooooo"
    end
end

FactoryGirl.define do 
    factory :phenotype do |p|
  p.characteristic "Penis length"
    end
end

FactoryGirl.define do
    factory :user_phenotype do |up|
  up.association :user
  up.association :phenotype
  up.variation "pink"
    end
end
