# frozen_string_literal: true

FactoryBot.define do
  factory :user_picture_phenotype do
    phenotype_picture { File.new(Rails.root.join('spec/fixtures/files/image.png')) }
    variation { 'pink' }
  end
end
