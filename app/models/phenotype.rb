class Phenotype < ActiveRecord::Base
  has_many :user_phenotypes, dependent: :destroy
  has_many :phenotype_comments, dependent: :destroy
  has_and_belongs_to_many :phenotype_sets

  validates_presence_of :characteristic

  searchable do
    text :characteristic
  end
  
  def known_phenotypes
    if @known_phenotypes.nil?
      @known_phenotypes =
        user_phenotypes.select('variation').all.
        map!(&:variation).
        map!(&:capitalize!)
      @known_phenotypes.uniq!
      @known_phenotypes.compact
    end
    @known_phenotypes
  end
  
end
