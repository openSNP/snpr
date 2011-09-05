class MendeleyPaper < ActiveRecord::Base
   belongs_to :snp

   searchable do
      text :title
   end
end
