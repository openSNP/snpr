class PgpAnnotation < ActiveRecord::Base
  include PgSearch

   belongs_to :snp

  pg_search_scope :search, against: [:search, :summary, :trait]
end
