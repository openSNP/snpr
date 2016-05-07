class PhenotypeSnp < ActiveRecord::Base
  include PgSearchCommon

  belongs_to :snp
  belongs_to :phenotype
end

