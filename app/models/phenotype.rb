class Phenotype < ActiveRecord::Base
   has_many :user_phenotypes
   has_many :phenotype_comments
   serialize :known_phenotypes

   validates_presence_of :characteristic

   searchable do
	   text :characteristic
   end
   
   after_create :default_array
   
   def default_array
     self.known_phenotypes ||= []
   end
   
end
