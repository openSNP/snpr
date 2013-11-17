class GenomeGovPaper < ActiveRecord::Base
  has_many :references, as: :paper
  has_many :snps, through: :references

  searchable do
    text :title
  end
end
