class PhenotypeComment < ActiveRecord::Base
   belongs_to :phenotype
   belongs_to :user
   
   searchable do
      text :comment_text, :subject
   end                     
end
