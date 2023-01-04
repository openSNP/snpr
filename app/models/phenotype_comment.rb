# frozen_string_literal: true

class PhenotypeComment < ApplicationRecord
  include PgSearchCommon

  belongs_to :phenotype
  belongs_to :user

  pg_search_common_scope against: [:comment_text, :subject]
end
