# frozen_string_literal: true

class UserSnp < ApplicationRecord
  belongs_to :snp, foreign_key: :snp_name, primary_key: :name, counter_cache: true
  belongs_to :genotype
  has_one :user, through: :genotype

  validates_presence_of :snp
  validates_presence_of :genotype

  def local_genotype
    self[:local_genotype].strip
  end
end
