# frozen_string_literal: true
class PicturePhenotype < ApplicationRecord
  include PgSearchCommon

  has_many :user_picture_phenotypes, dependent: :destroy
  has_many :picture_phenotype_comments, dependent: :destroy
  #has_and_belongs_to_many :phenotype_sets

  validates_presence_of :characteristic

  pg_search_common_scope against: :characteristic
end
