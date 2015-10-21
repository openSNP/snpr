class UserSnp < ActiveRecord::Base
  self.primary_keys = [:genotype_id, :snp_name]
  belongs_to :snp, foreign_key: :snp_name, primary_key: :name, counter_cache: true
  has_one :user, through: :genotype
  belongs_to :genotype

  validates_presence_of :snp
  validates_presence_of :genotype

  def local_genotype
    self[:local_genotype].strip
  end
end
