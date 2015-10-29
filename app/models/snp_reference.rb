class SnpReference < ActiveRecord::Base
  self.primary_keys = :snp_id, :paper_id, :paper_type
  belongs_to :snp
  belongs_to :paper, polymorphic: true
  #validates_presence_of :snp, :paper
  validates :snp_id, uniqueness: { scope: [:paper_id, :paper_type]}
end
