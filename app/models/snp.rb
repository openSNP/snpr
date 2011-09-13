class Snp < ActiveRecord::Base
  has_many :user_snps, foreign_key: :snp_name
  has_many :plos_paper
  has_many :mendeley_paper
  has_many :snpedia_paper
  has_many :snp_comments
  serialize :allele_frequency
  serialize :genotype_frequency

  searchable do
    text :name
  end

  after_create :default_frequencies

  def default_frequencies
    # if variations is empty, put in our default array
    self.allele_frequency ||= { "A" => 0, "T" => 0, "G" => 0, "C" => 0}
    self.genotype_frequency ||= {}
  end

  def self.update_em_all snps
    return 0 if snps.empty?
    ActiveRecord::Base.connection.execute(snps.map do |snp|
      "update snps set (#{snp.changed.join(',')}) = (#{snp.changed.map {|a| snp.send(a.to_sym) }.join(',') }) where id = #{snp.id} limit 1; "
    end.join)
  end
end
