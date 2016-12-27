# frozen_string_literal: true
class Phenotype < ActiveRecord::Base
  include PgSearchCommon

  has_many :user_phenotypes, dependent: :destroy
  has_many :phenotype_comments, dependent: :destroy
  has_and_belongs_to_many :phenotype_sets

  validates :characteristic, presence: true

  accepts_nested_attributes_for :user_phenotypes

  pg_search_common_scope against: :characteristic

  def number_of_users
    user_phenotypes.count
  end

  def known_phenotypes
    user_phenotypes
      .pluck(:variation)
      .map(&:capitalize)
      .uniq
  end

  def self.with_number_of_users
    from(
      select('phenotypes.*, count(user_phenotypes.*) as number_of_users')
        .joins('LEFT JOIN user_phenotypes ON user_phenotypes.phenotype_id = phenotypes.id')
        .group(1)
        .as('phenotypes')
    )
  end

  def number_of_users
    self[:number_of_users] || user_phenotypes.count
  end
end

