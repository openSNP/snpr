class Phenotype < ActiveRecord::Base
  has_many :user_phenotypes, dependent: :destroy
  has_many :phenotype_comments, dependent: :destroy

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
