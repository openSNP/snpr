FactoryGirl.define do
  factory :user_snp do
    local_genotype 'AG'
    genotype
    user
    snp
  end
end
