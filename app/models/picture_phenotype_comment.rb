# frozen_string_literal: true
class PicturePhenotypeComment < ActiveRecord::Base
  include PgSearchCommon

  belongs_to :picture_phenotype
  belongs_to :user

  pg_search_common_scope against: [:comment_text, :subject]
end
