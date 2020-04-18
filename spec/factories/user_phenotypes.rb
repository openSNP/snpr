# frozen_string_literal: true

FactoryBot.define do
  factory :user_phenotype do
    association :user
    association :phenotype
    variation { 'pink' }
  end
end
