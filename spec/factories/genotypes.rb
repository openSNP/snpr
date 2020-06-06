# frozen_string_literal: true

FactoryBot.define do
  factory :genotype do
    genotype_file_name { 'foo.txt' }
    user
  end
end
