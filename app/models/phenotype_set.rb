class PhenotypeSet < ActiveRecord::Base
  include PgSearch

  has_and_belongs_to_many :phenotypes

  validates_presence_of :title,:description

  pg_search_scope :search, against: :title
end
