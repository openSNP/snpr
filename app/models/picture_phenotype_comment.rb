class PicturePhenotypeComment < ActiveRecord::Base
   belongs_to :picture_phenotype
   belongs_to :user
   
   searchable do
      text :comment_text, :subject
   end                     
end
