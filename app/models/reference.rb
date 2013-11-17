class Reference < ActiveRecord::Base
  belongs_to :snp
  belongs_to :paper, polymorphic: true
  validates_presence_of :snp, :paper
end
