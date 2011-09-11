class UserSnp < ActiveRecord::Base
  belongs_to :snp
  belongs_to :user
  belongs_to :genotype
end
