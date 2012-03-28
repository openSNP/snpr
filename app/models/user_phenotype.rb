class UserPhenotype < ActiveRecord::Base
   belongs_to :phenotype, dependent: :destroy
   belongs_to :user
   validates_presence_of :variation

   attr_accessible :variation,:phenotype_id,:js_modal

   searchable do
     text :variation
   end
end
