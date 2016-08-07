class Phenotype < ActiveRecord::Base
  include PgSearchCommon

  has_many :user_phenotypes, dependent: :destroy
  has_many :phenotype_comments, dependent: :destroy
  has_and_belongs_to_many :phenotype_sets

  validates_presence_of :characteristic

  pg_search_common_scope against: :characteristic

  def known_phenotypes
    if @known_phenotypes.nil?
      @known_phenotypes = user_phenotypes.pluck(:variation).map(&:capitalize)
      @known_phenotypes.uniq!
      @known_phenotypes.compact
    end
    @known_phenotypes
  end

  def self.with_number_of_users
    select('phenotypes.*, count(user_phenotypes.*) as number_of_users')
      .joins('LEFT JOIN user_phenotypes ON user_phenotypes.phenotype_id = phenotypes.id')
      .group(1)
  end

  def number_of_users
    self[:number_of_users] || user_phenotypes.count
  end
end

