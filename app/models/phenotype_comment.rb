class PhenotypeComment < ActiveRecord::Base
  include PgSearch

  belongs_to :phenotype
  belongs_to :user

  pg_search_scope :search, against: [:comment_text, :subject]
end
