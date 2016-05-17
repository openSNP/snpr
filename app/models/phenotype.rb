class Phenotype < ActiveRecord::Base
  include PgSearchCommon

  has_many :user_phenotypes, dependent: :destroy
  has_many :phenotype_comments, dependent: :destroy
  has_and_belongs_to_many :phenotype_sets

  has_many :phenotype_snps
  has_many :snps, through: :phenotype_snps

  validates_presence_of :characteristic

  pg_search_common_scope against: :characteristic

  def known_phenotypes
    if @known_phenotypes.nil?
      @known_phenotypes = user_phenotypes.pluck(:variation).map(&:capitalize)
      @known_phenotypes.uniq!
      @known_phenotypes.compact
    end
    @known_phenotypes
  end
end

