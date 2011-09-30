class UserPhenotype < ActiveRecord::Base
   belongs_to :phenotype
   belongs_to :user
   validates_presence_of :variation
   
   searchable do
	   text :variation
   end
end
