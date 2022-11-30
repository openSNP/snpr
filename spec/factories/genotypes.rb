# frozen_string_literal: true

FactoryBot.define do
  factory :genotype do
    genotype { File.new(Rails.root.join('spec/fixtures/files/genotype.txt')) }
    user
  end
end
