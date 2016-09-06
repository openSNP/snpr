class PhenotypeSnp < ActiveRecord::Base
  include PgSearchCommon

  belongs_to :snp
  belongs_to :phenotype

  validates :snp, :presence => true
  validates :phenotype, :presence => true

  def self.update_phenotypes
    max_age = 30.days.ago

    Snp.select([ :id, :ranking ]).
      where([ 'updated_at > ?', max_age]).find_each do |snp|
      LinkSnpPhenotype.perform_async(snp.id)
    end
  end
end

