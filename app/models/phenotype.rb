class Phenotype < ActiveRecord::Base
   has_many :user_phenotypes
   has_many :phenotype_comments
   serialize :known_phenotypes

   validates_presence_of :characteristic

   searchable do
	   text :characteristic
   end
   
   def known_phenotypes
     read_attribute(:known_phenotypes) || []
   end
end
