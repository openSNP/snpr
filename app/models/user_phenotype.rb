class UserPhenotype < ActiveRecord::Base
   belongs_to :phenotype
   belongs_to :user
end
