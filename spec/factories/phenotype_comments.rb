# frozen_string_literal: true

FactoryBot.define do
  factory :phenotype_comment do
    phenotype
    user
  end
end
