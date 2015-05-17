class UserSnp < ActiveRecord::Base
  self.table_name = 'user_snps_master'
  self.primary_keys = [:snp_name, :genotype_id]

  belongs_to :snp, foreign_key: :snp_name, primary_key: :name, counter_cache: true
  has_one :user, through: :genotype
  belongs_to :genotype

  validates :snp, presence: true
  validates :genotype, presence: true
  validates :local_genotype, presence: true
end
