class SnpComment < ActiveRecord::Base
   belongs_to :snp
   belongs_to :user
   
end
