# frozen_string_literal: true
class SnpComment < ActiveRecord::Base
  include PgSearchCommon

  belongs_to :snp
  belongs_to :user

  pg_search_common_scope against: :subject
end
