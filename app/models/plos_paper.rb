class PlosPaper < ActiveRecord::Base
   belongs_to :snp

   searchable do
	   text :title
   end
end
