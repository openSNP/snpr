class PicturePhenotype < ActiveRecord::Base
  include PgSearch

  has_many :user_picture_phenotypes, dependent: :destroy
  has_many :picture_phenotype_comments, dependent: :destroy
  #has_and_belongs_to_many :phenotype_sets

  validates_presence_of :characteristic

  pg_search_scope :search, against: :characteristic
end
