class Phenotype < ActiveRecord::Base
   has_many :user_phenotypes

   searchable do
	   text :characteristic
   end
end
