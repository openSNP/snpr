# frozen_string_literal: true
FactoryBot.define do
  factory :user_snp do
    local_genotype 'AG'
    genotype
    user
    snp
  end
end
