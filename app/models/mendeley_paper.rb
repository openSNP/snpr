class MendeleyPaper < ActiveRecord::Base
  include PgSearchCommon

  has_many :snp_references, as: :paper
  has_many :snps, through: :snp_references
  validates_presence_of :title, :uuid
  validates_uniqueness_of :uuid

  pg_search_common_scope against: :title

  def first_author
    read_attribute(:first_author).presence || 'Unknown'
  end
end
