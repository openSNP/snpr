class Phenotype < ActiveRecord::Base
   has_many :user_phenotypes
   serialize :known_phenotypes

   searchable do
	   text :characteristic
   end
   
   after_create :default_array
   
   def default_array
     self.known_phenotypes ||= []
   end
end