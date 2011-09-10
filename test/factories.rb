Factory.define :user do |u|
  u.email "fubert@example.org"
  u.password "jeheim"
  u.password_confirmation "jeheim"
end

Factory.define :genotype do |g|
  g.originalfilename "foo.txt"
  g.uploadtime { Time.now }
  g.association :user
end
