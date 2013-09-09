class Snp < ActiveRecord::Base
  has_many :user_snps, foreign_key: :snp_name, primary_key: :name,
    dependent: :destroy
  has_many :plos_paper
  has_many :mendeley_paper, dependent: :destroy
  has_many :snpedia_paper
  has_many :snp_comments
  has_many :genome_gov_paper
  has_many :pgp_annotation
  serialize :allele_frequency
  serialize :genotype_frequency

  extend FriendlyId
  friendly_id :name, :use => :history, :slug_column => :name

  validates_uniqueness_of :name

  searchable do
    text :name
  end

  after_create :default_frequencies

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
      Sidekiq::Client.enqueue(Mendeley, snp.id) if snp.mendeley_updated < max_age
      Sidekiq::Client.enqueue(Snpedia,  snp.id) if snp.snpedia_updated  < max_age
      Sidekiq::Client.enqueue(Plos,     snp.id) if snp.plos_updated     < max_age
    end
  end
  
  def self.update_frequencies
    Snp.find_each do |s|
      Sidekiq::Client.enqueue(Frequency,s.id)
    end
  end
end
