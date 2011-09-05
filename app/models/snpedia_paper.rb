class SnpediaPaper < ActiveRecord::Base
   belongs_to :snp

   searchable do
      text :summary
   end
end
