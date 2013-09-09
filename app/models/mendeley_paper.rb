class MendeleyPaper < ActiveRecord::Base
   belongs_to :snp
   validates_presence_of :title, :snp, :uuid
   validates_uniqueness_of :uuid

   searchable do
      text :title
   end

   def first_author
     read_attribute(:first_author).presence || "Unknown"
   end
end
