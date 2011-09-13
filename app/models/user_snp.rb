class UserSnp < ActiveRecord::Base
  belongs_to :snp, foreign_key: :snp_name
  belongs_to :user
  belongs_to :genotype
end
