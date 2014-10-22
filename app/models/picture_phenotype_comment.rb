class PicturePhenotypeComment < ActiveRecord::Base
  include PgSearch

  belongs_to :picture_phenotype
  belongs_to :user

  pg_search_scope :search, against: [:comment_text, :subject]
end
