class MendeleyPaper < ActiveRecord::Base
  has_many :snp_references, as: :paper
  has_many :snps, through: :snp_references
  validates_presence_of :title, :uuid
  validates_uniqueness_of :uuid

  searchable do
    text :title
  end

  def first_author
    read_attribute(:first_author).presence || "Unknown"
  end
end
