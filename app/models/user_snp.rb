class UserSnp < ActiveRecord::Base
  self.table_name = 'user_snps_master'
  self.primary_keys = [:snp_name, :genotype_id]

  belongs_to :snp, foreign_key: :snp_name, primary_key: :name, counter_cache: true
  has_one :user, through: :genotype
  belongs_to :genotype

  validates_presence_of :snp
  validates_presence_of :genotype
  validates_presence_of :local_genotype
end
