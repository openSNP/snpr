class Snp < ActiveRecord::Base
  include PgSearchCommon
  extend IgnoreColumns

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

  ignore_columns :genotypes

  def genotypes
    genotype_ids = self.class.unscoped
                             .select('unnest(akeys(genotypes)::int[])')
                             .where(id: id)
    Genotype.where(id: genotype_ids)
  end

  def genotypes_count
    @genotype_count ||= self.class.where(id: id)
                                  .pluck('array_length(akeys(genotypes), 1)')
                                  .first
  end

  def self.with_local_genotype_for(genotype)
    genotype_id = case genotype
                  when Genotype then genotype.id
                  when Integer then genotype
                  else fail TypeError, "Expected Genotype or Integer, got #{genotype.class}"
                  end
    select("genotypes -> #{ActiveRecord::Base.sanitize(genotype_id.to_s)} AS local_genotype")
  end

  def users
    User.select('users.*').joins(:genotypes).merge(genotypes)
  end

  def default_frequencies
    # if variations is empty, put in our default array
    self.allele_frequency ||= { "A" => 0, "T" => 0, "G" => 0, "C" => 0}
    self.genotype_frequency ||= {}
  end

  def self.update_papers
    max_age = 31.days.ago

    snps = Snp.select([ :id, :mendeley_updated, :snpedia_updated, :plos_updated ]).
      where([ 'mendeley_updated < ? or snpedia_updated < ? or plos_updated < ?',
              max_age, max_age, max_age ]).find_each do |snp|
      Sidekiq::Client.enqueue(Mendeley,   snp.id) if snp.mendeley_updated < max_age
      Sidekiq::Client.enqueue(Snpedia,    snp.id) if snp.snpedia_updated  < max_age
      Sidekiq::Client.enqueue(PlosSearch, snp.id) if snp.plos_updated     < max_age
    end
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
end
