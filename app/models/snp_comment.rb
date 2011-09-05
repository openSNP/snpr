class SnpComment < ActiveRecord::Base
   belongs_to :snp
   belongs_to :user
   
   searchable do
      text :comment_text, :subject
   end
end
