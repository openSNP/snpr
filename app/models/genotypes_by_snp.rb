class GenotypesBySnp < ActiveRecord::Base
  self.table_name = 'genotypes_by_snp'
  self.primary_key = 'snp_name'

  belongs_to :snp, primary_key: :name, foreign_key: :snp_name
end
