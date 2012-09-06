class UserPhenotype < ActiveRecord::Base
  belongs_to :phenotype
  belongs_to :user
  validates_presence_of :variation

  attr_accessible :variation,:phenotype_id,:js_modal

  searchable do
    text :variation
    integer :phenotype_id
  end
end
