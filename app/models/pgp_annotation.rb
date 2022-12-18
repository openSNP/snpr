# frozen_string_literal: true

class PgpAnnotation < ApplicationRecord
  include PgSearchCommon

   belongs_to :snp

  pg_search_common_scope against: [:search, :summary, :trait]
end
