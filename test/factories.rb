Factory.define :user do |u|
  u.name "Dogbert"
  u.sequence(:email) { |i| "fubert#{i}@example.org" }
  u.password "jeheim"
  u.password_confirmation "jeheim"
  u.sex 'yes please'
  u.yearofbirth '1970'
end

Factory.define :genotype do |g|
  g.originalfilename "foo.txt"
  g.uploadtime { Time.now }
  g.association :user
end

Factory.define :snp do |s|
  s.sequence(:name) { |i| "name #{i}" }
  s.sequence(:position) { |i| i }
  s.sequence(:chromosome) { |i| i }
  s.genotype_frequency("AA" => 1)
  s.allele_frequency("A" => 0, "T" => 0, "G" => 0, "C" => 0)
  s.ranking 0
end

Factory.define :achievement do |a|
  a.award "Foooooooo"
end

Factory.define :phenotype do |p|
  p.characteristic "Penis length"
  p.known_phenotypes [ "foo", "bar" ]
end

Factory.define :user_phenotype do |up|
  up.association :user
  up.association :phenotype
  up.variation "pink"
end
