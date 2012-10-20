class PgpAnnotation < ActiveRecord::Base
   belongs_to :snp

   searchable do
	   text :gene
	   text :summary
	   text :trait
   end
end
