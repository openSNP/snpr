class UserSnp < ActiveRecord::Base
  belongs_to :snp, foreign_key: :snp_name, primary_key: :name,
    counter_cache: true
  has_one :user, through: :genotype
  belongs_to :genotype

  validates_presence_of :snp
  validates_presence_of :genotype
end
