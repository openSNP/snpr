class Snp < ActiveRecord::Base
  include PgSearchCommon

  has_many :user_snps, foreign_key: :snp_name, primary_key: :name
  has_many :users, through: :user_snps
  has_many :pgp_annotations
  has_many :snp_references
  has_many :snp_comments

  serialize :allele_frequency
  serialize :genotype_frequency

  extend FriendlyId
  friendly_id :name, use: :history, slug_column: :name

  validates_uniqueness_of :name

  pg_search_common_scope against: :name

  after_create :default_frequencies

  def default_frequencies
    # if variations is empty, put in our default array
    self.allele_frequency ||= { "A" => 0, "T" => 0, "G" => 0, "C" => 0}
    self.genotype_frequency ||= {}
  end

  def self.update_frequencies
    Snp.find_each do |s|
      Sidekiq::Client.enqueue(Frequency,s.id)
    end
  end

  %w(snpedia mendeley genome_gov plos).each do |source|
    define_method(:"#{source}_papers") do
      klass = "#{source.camelize}Paper".constantize
      klass.joins(:snp_references).where(snp_references: { snp_id: id })
    end

    define_method(:"#{source}_updated!") do
      update_column(:"#{source}_updated", Time.current)
      update_ranking
    end
  end

  def update_ranking
    rank = mendeley_papers.count   +
      2 * plos_papers.count       +
      5 * snpedia_papers.count    +
      2 * genome_gov_papers.count +
      2 * pgp_annotations.count
    update_column(:ranking, rank)
  end

  def total_genotypes
    genotype_frequency.values.sum
  end

  def total_alleles
    allele_frequency.values.sum
  end

  def get_last_updated
    # Gets the paper that was last updated for this SNP
    last_updated_time = Time.new 1970
    last_updated = nil
    %w(snpedia mendeley genome_gov plos).each do |source|
      klass = "#{source}_papers"
      klass_last = send(klass).last
      if !klass_last.nil? && klass_last.created_at > last_updated_time
        last_updated_time = klass_last.created_at
        last_updated = source.capitalize
      end
    end
    last_updated
  end
end
