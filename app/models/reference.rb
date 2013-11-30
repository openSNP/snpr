class Reference < ActiveRecord::Base
  belongs_to :snp
  belongs_to :paper, polymorphic: true
  belongs_to :snpedia_paper
  validates_presence_of :snp, :paper
end
