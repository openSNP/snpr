class GenomeGovPaper < ActiveRecord::Base
  include PgSearch

  has_many :snp_references, as: :paper
  has_many :snps, through: :snp_references

  pg_search_scope :search, against: :title
end
