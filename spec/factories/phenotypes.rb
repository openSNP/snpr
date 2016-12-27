# frozen_string_literal: true
FactoryGirl.define do
  factory :phenotype do
    characteristic 'Penis length'

    factory :phenotype_with_users do
      after :create do |t|
        3.times { create(:user_phenotype, phenotype: t) }
      end
    end
  end
end
