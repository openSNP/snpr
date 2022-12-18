# frozen_string_literal: true
class PlosPaper < ApplicationRecord
  include PgSearchCommon

  has_many :snp_references, as: :paper
  has_many :snps, through: :snp_references

  pg_search_common_scope against: :title
end
