class Phenotype < ActiveRecord::Base
  has_many :user_phenotypes
  has_many :phenotype_comments
  serialize :known_phenotypes

  validates_presence_of :characteristic

  searchable do
    text :characteristic
  end
  
  def known_phenotypes
    @known_phenotypes ||=
      user_phenotypes.map(&:variation).
      map(&:downcase).
      uniq.
      map(&:camelize)
  end
  
end
