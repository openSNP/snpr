FactoryGirl.define do
  factory :mendeley_paper do
    title 'Musterstudie'
    uuid { UUIDTools::UUID.random_create.to_s }
    first_author 'Max Mustermann'
    mendeley_url 'http://example.com'
    doi '10.1000/182'
    pub_year 2013
  end
end
