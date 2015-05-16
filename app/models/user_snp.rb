class UserSnp < ActiveRecord::Base
  self.table_name = 'user_snps_master'

  #self.primary_keys = [:genotype_id, :snp_name]
  belongs_to :snp, foreign_key: :snp_name, primary_key: :name, counter_cache: true
  #has_one :user, through: :genotype
  #belongs_to :genotype

  validates_presence_of :snp
  #validates_presence_of :genotype

  def self.by_genotype(genotype)
    genotype_id = case genotype
                  when Genotype then genotype.id
                  when Fixnum then genotype
                  else fail "Cannot deduct genotype_id from #{genotype.inspect}"
                  end

    select("user_snps_#{genotype_id}.*")
      .from("user_snps_#{genotype_id}")
  end
end
