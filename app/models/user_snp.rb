class UserSnp < ActiveRecord::Base
  belongs_to :snp, foreign_key: :snp_name, primary_key: :name
  belongs_to :user
  belongs_to :genotype
end
