class UserSnp < ActiveRecord::Base
  belongs_to :snp
  belongs_to :user
  belongs_to :genotype

  validates_presence_of :snp
end
