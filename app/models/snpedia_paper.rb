class SnpediaPaper < ActiveRecord::Base
  include PgSearchCommon

  has_many :snp_references, as: :paper
  has_many :snps, through: :snp_references

  pg_search_common_scope against: :summary

  def summary
    read_attribute(:summary).presence || "No summary provided."
  end

  def snp_variation
    url =~ /\((.*);(.*)\)$/
    "#{$1}#{$2}"
  end
end
