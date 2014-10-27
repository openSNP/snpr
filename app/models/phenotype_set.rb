class PhenotypeSet < ActiveRecord::Base
  include PgSearchCommon

  has_and_belongs_to_many :phenotypes

  validates_presence_of :title,:description

  pg_search_common_scope against: :title
end
