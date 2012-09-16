class PhenotypeSet < ActiveRecord::Base
  has_and_belongs_to_many :phenotypes

  validates_presence_of :title,:description

  searchable do
    text :title
  end
  
end
