class Snp < ActiveRecord::Base
   has_many :user_snps
   serialize :allele_frequency
   serialize :genotype_frequency
end
