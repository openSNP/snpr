class SnpediaPaper < ActiveRecord::Base
  include PgSearch

  has_many :snp_references, as: :paper
  has_many :snps, through: :snp_references

  pg_search_scope :search, against: :summary

  def summary
    read_attribute(:summary).presence || "No summary provided."
  end
end
