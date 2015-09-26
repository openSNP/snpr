class SnpsByGenotype < ActiveRecord::Base
  self.table_name = 'snps_by_genotype'
  self.primary_key = 'genotype_id'

  belongs_to :genotype
end
