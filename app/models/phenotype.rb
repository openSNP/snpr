class Phenotype < ActiveRecord::Base
  has_many :user_phenotypes, dependent: :destroy
  has_many :phenotype_comments, dependent: :destroy
  has_and_belongs_to_many :phenotype_sets

  validates_presence_of :characteristic

  searchable do
    text :characteristic
  end
  
  def known_phenotypes
    @known_phenotypes ||=
      user_phenotypes.map(&:variation).
      map(&:downcase).
      uniq.
      map(&:camelize).
      each do |up|
        up.gsub!("::","/")
      end
  end
  
end
