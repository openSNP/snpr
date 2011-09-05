class Snp < ActiveRecord::Base
   has_many :user_snps
   has_many :plos_paper
   has_many :mendeley_paper
   has_many :snpedia_paper
   has_many :snp_comments
   serialize :allele_frequency
   serialize :genotype_frequency
   
   after_create :default_frequencies

   def default_frequencies
	   # if variations is empty, put in our default array
	   self.allele_frequency ||= { "A" => 0, "T" => 0, "G" => 0, "C" => 0}
	   self.genotype_frequency ||= {}
   end
end
