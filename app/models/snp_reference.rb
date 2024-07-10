# frozen_string_literal: true

class SnpReference < ApplicationRecord
  belongs_to :snp
  belongs_to :paper, polymorphic: true
  validates_presence_of :snp, :paper
  validates :snp_id, uniqueness: { scope: [:paper_id, :paper_type]}
end
